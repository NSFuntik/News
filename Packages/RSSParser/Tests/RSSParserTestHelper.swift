//
//  RSSParserTestHelper.swift
//  RSSParser
//
//  Created by NSFuntik on 11/18/24.
//

@testable import RSSDomain
import Foundation
import XCTest

/// Test helper class for RSS parser tests
@available(macOS 12.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
final class RSSParserTestHelper {
  /// The test bundle containing resources for the RSS parser tests.
  ///
  /// This uses a static property to locate the appropriate bundle that contains
  /// the required XML resources for testing. It checks the module bundle first,
  /// and if that fails, attempts to load from a local resources directory.
  static let testBundle: Bundle = {
    let bundleName = "Tests_Resources"
    let candidates = [
      Bundle.module,
      Bundle(for: RSSParserTestHelper.self),
    ]

    for bundle in candidates {
      print("Checking bundle: \(bundle.bundlePath)")
      if let xmlPath = bundle.path(forResource: "ValidRSS", ofType: "xml", inDirectory: "Resources") {
        print("Found test resources in bundle: \(bundle.bundlePath)")
        return bundle
      }
    }

    // if we still didnt found it, try direct path to resources
    let thisFile = URL(fileURLWithPath: #file)
    let testsDirectory = thisFile.deletingLastPathComponent()
    let resourcesDirectory = testsDirectory.appendingPathComponent("Resources")

    if let bundle = Bundle(url: resourcesDirectory) {
      print("Using resources directory directly: \(resourcesDirectory.path)")
      return bundle
    }

    fatalError("Could not find test resources bundle")
  }()

  /// Loads XML test data from the test bundle.
  ///
  /// Tries to locate and load an XML file with the given name from the test
  /// bundle's resources directory, or any available path in the bundle.
  /// If the file cannot be found, it throws a `RSSError.invalidData` error.
  ///
  /// - Parameter name: The name of the XML file (without extension) to load.
  /// - Throws: An error if the XML file cannot be found or read.
  /// - Returns: The data of the XML file.
  static func loadTestXML(_ name: String) throws -> Data {
    print("Loading \(name).xml from test bundle: \(testBundle.bundlePath)")

    if let url = testBundle.url(forResource: name, withExtension: "xml", subdirectory: "Resources") {
      print("Found resource at: \(url.path)")
      return try Data(contentsOf: url)
    }

    if let url = testBundle.url(forResource: name, withExtension: "xml") {
      print("Found resource at root: \(url.path)")
      return try Data(contentsOf: url)
    }

    let resourcesPath = URL(fileURLWithPath: testBundle.bundlePath)
      .appendingPathComponent("Resources")
      .appendingPathComponent("\(name).xml")

    if FileManager.default.fileExists(atPath: resourcesPath.path) {
      print("Found resource at direct path: \(resourcesPath.path)")
      return try Data(contentsOf: resourcesPath)
    }

    print("Available resources in test bundle:")
    if let resources = testBundle.urls(forResourcesWithExtension: "xml", subdirectory: nil) {
      resources.forEach { print($0.path) }
    } else {
      print("No XML resources found in bundle")
    }

    print("Current directory: \(FileManager.default.currentDirectoryPath)")
    print("Bundle path: \(testBundle.bundlePath)")

    throw RSSError.invalidData(reason: "Missing test file: \(name).xml")
  }

  /// Creates a mock network service for testing.
  ///
  /// This function provides a convenience to create a `NetworkService` with
  /// optional mock data and error to simulate specific network responses in
  /// unit tests.
  ///
  /// - Parameters:
  ///   - data: Optional mock data to be returned on fetch.
  ///   - error: Optional error to be thrown on fetch.
  /// - Returns: A configured `NetworkService` instance.
  static func mockNetworkService(withData data: Data? = nil, error: Error? = nil) -> NetworkService {
    MockNetworkService(mockData: data, mockError: error)
  }

  /// Validates an `RSSItem` against expected properties.
  ///
  /// This function asserts the properties of an `RSSItem` against the values
  /// passed as parameters using `XCTAssertEqual` and related methods.
  /// It ensures that all relevant fields match expected values, throwing
  /// assertion failures if there are discrepancies.
  ///
  /// - Parameters:
  ///   - item: The `RSSItem` to validate.
  ///   - id: Expected item ID.
  ///   - title: Expected item title.
  ///   - description: Expected item description.
  ///   - link: Expected item link.
  ///   - pubDate: Expected publication date (optional).
  ///   - author: Expected author name (optional).
  ///   - categories: Expected categories (optional, defaults to empty).
  ///   - content: Expected content (optional).
  ///   - enclosure: Expected enclosure (optional).
  ///   - file: The file where the assertion is being made.
  ///   - line: The line number where the assertion is being made.
  static func validateRSSItem(
    _ item: RSSItem,
    id: String,
    title: String,
    description: String,
    link: String,
    pubDate: Date?,
    author: String? = nil,
    categories: [String] = [],
    content: String? = nil,
    enclosure: RSSEnclosure? = nil,
    file: StaticString = #file,
    line: UInt = #line
  ) {
    XCTAssertEqual(item.id, id, "Item ID mismatch", file: file, line: line)
    XCTAssertEqual(item.title, title, "Item title mismatch", file: file, line: line)
    XCTAssertEqual(item.description, description, "Item description mismatch", file: file, line: line)
    XCTAssertEqual(item.link.absoluteString, link, "Item link mismatch", file: file, line: line)

    if let pubDate = pubDate {
      XCTAssertEqual(item.pubDate, pubDate, "Item pubDate mismatch", file: file, line: line)
    } else {
      XCTAssertNotNil(item.pubDate, "Item pubDate should not be nil", file: file, line: line)
    }

    XCTAssertEqual(item.author, author, "Item author mismatch", file: file, line: line)
    XCTAssertEqual(item.categories, categories, "Item categories mismatch", file: file, line: line)
    XCTAssertEqual(item.content, content, "Item content mismatch", file: file, line: line)

    if let expectedEnclosure = enclosure {
      XCTAssertNotNil(item.enclosure, "Item should have enclosure", file: file, line: line)
      XCTAssertEqual(item.enclosure?.url, expectedEnclosure.url, "Enclosure URL mismatch", file: file, line: line)
      XCTAssertEqual(item.enclosure?.type, expectedEnclosure.type, "Enclosure type mismatch", file: file, line: line)
      XCTAssertEqual(item.enclosure?.length, expectedEnclosure.length, "Enclosure length mismatch", file: file, line: line)
    } else {
      XCTAssertNil(item.enclosure, "Item should not have enclosure", file: file, line: line)
    }
  }

  /// Configures a mock URL session for testing.
  ///
  /// This helper method returns a `URLSessionConfiguration` with a custom
  /// handler for requests that can be used in testing scenarios to simulate
  /// various network conditions.
  ///
  /// - Parameter handler: A closure that handles URL requests and provides
  ///                     the expected response and data.
  /// - Returns: A configured `URLSessionConfiguration`.
  static func mockURLSessionConfiguration(
    handler: @escaping MockURLProtocol.Handler
  ) -> URLSessionConfiguration {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    MockURLProtocol.requestHandler = handler
    return config
  }
}

/// Simple mock for URLProtocol
@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
final class MockURLProtocol: URLProtocol {
  typealias Handler = (URLRequest) throws -> (URLResponse, Data)
  static var requestHandler: Handler?

  override class func canInit(with request: URLRequest) -> Bool {
    return true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }

  override func startLoading() {
    guard let handler = MockURLProtocol.requestHandler else {
      XCTFail("Handler not set")
      return
    }

    do {
      let (response, data) = try handler(request)
      client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      client?.urlProtocol(self, didLoad: data)
      client?.urlProtocolDidFinishLoading(self)
    } catch {
      client?.urlProtocol(self, didFailWithError: error)
    }
  }

  override func stopLoading() {}
}

/// Simple mock for NetworkService
@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
final class MockNetworkService: NetworkService {
  let mockData: Data?
  let mockError: Error?

  init(mockData: Data? = nil, mockError: Error? = nil) {
    self.mockData = mockData
    self.mockError = mockError
  }

  func fetchData(from url: URL) async throws -> Data {
    if let error = mockError {
      throw error
    }
    return mockData ?? Data()
  }
}
