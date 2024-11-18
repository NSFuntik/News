//
//  RSSParserTests.swift
//
//  Created by NSFuntik on 11/18/24.
//
@testable import Data
@testable import Domain
import Foundation
import XCTest

final class RSSParserTests: XCTestCase {

  private var repository: RSSRepositoryImpl!
  private var networkService: NetworkService!
  private var parser: RSSParser!
  private let helper = RSSParserTestHelper()

  // MARK: - Setup & Teardown

  override func setUpWithError() throws {
    try super.setUpWithError()

    print("Current directory: \(FileManager.default.currentDirectoryPath)")
    print("Test bundle path: \(RSSParserTestHelper.testBundle.bundlePath)")
    if let resources = RSSParserTestHelper.testBundle.urls(forResourcesWithExtension: "xml", subdirectory: nil) {
      print("Available resources:")
      resources.forEach { print($0.path) }
    }

    networkService = DefaultNetworkService()
    parser = RSSParserImpl()
    repository = RSSRepositoryImpl(networkService: networkService, rssParser: parser)
  }

  // MARK: - Basic Parsing Tests

  /// multiple items
  func testValidRSSParsing() async throws {
    let data = try RSSParserTestHelper.loadTestXML("ValidRSS")

    do {
      let items = try await parser.parse(data)
      XCTAssertFalse(items.isEmpty, "Parsed items should not be empty")
      XCTAssertEqual(items.count, 2, "Parsed items count should be 2")

      RSSParserTestHelper.validateRSSItem(
        items[0],
        id: "1234",
        title: "Test Title 1",
        description: "Test Description 1",
        link: "https://example.com/1",
        pubDate: nil,
        author: "test@example.com (Test Author)",
        categories: ["Test Category 1"]
      )

      RSSParserTestHelper.validateRSSItem(
        items[1],
        id: "5678",
        title: "Test Title 2",
        description: "Test Description 2",
        link: "https://example.com/2",
        pubDate: nil,
        author: "test@example.com (Test Author)",
        categories: ["Test Category 2"]
      )
    } catch {
      XCTFail("Parsing valid RSS should not throw: \(error)")
    }
  }

  // MARK: - Error Handling Tests

  /// malformed XML
  func testInvalidRSSParsing() async throws {
    let invalidXML = "<rss><channel><item><title>Test</title></item></channel>".data(using: .utf8)!

    do {
      _ = try await parser.parse(invalidXML)
      XCTFail("Parsing malformed XML should throw")
    } catch let error as RSSError {
      XCTAssertNotNil(error.errorDescription)
      XCTAssertNotNil(error.failureReason)
      XCTAssertNotNil(error.recoverySuggestion)

      if case .parsingError(let underlying) = error {
        XCTAssertNotNil(underlying, "Underlying error should be present")
      } else {
        XCTFail("Unexpected error type: \(error)")
      }
    }
  }

  /// parsing of empty data
  func testParsingEmptyData() async throws {
    let emptyData = Data()

    do {
      _ = try await parser.parse(emptyData)
      XCTFail("Parsing empty data should throw")
    } catch let error as RSSError {
      XCTAssertEqual(error, .emptyData)
    }
  }

  // MARK: - Required Fields Tests

  func testRSSParsingMissingRequiredFields() async throws {
    let data = try RSSParserTestHelper.loadTestXML("MissingFieldsRSS")

    do {
      let items = try await parser.parse(data)
      XCTAssertFalse(items.isEmpty, "Items should parse even with missing fields")
      XCTAssertEqual(items.count, 1)

      let item = items[0]
      XCTAssertEqual(item.id, "https://example.com/1", "Should use link as ID if GUID missing")
      XCTAssertEqual(item.title, "Test Title without GUID")
      XCTAssertEqual(item.link.absoluteString, "https://example.com/1")
      XCTAssertNotNil(item.pubDate)
    } catch {
      XCTFail("Parsing with missing fields should not throw: \(error)")
    }
  }

  // MARK: - Date Format Tests

  func testRSSParsingMultipleDateFormats() async throws {
    let data = try RSSParserTestHelper.loadTestXML("DateFormatsRSS")

    do {
      let items = try await parser.parse(data)
      XCTAssertEqual(items.count, 3)

      for item in items {
        XCTAssertNotNil(item.pubDate, "Should parse dates in various formats")
      }
    } catch {
      XCTFail("Date format parsing failed: \(error)")
    }

    // Test malformed dates
    let malformedData = try RSSParserTestHelper.loadTestXML("RSSWithMalformedPubDate")
    let items = try await parser.parse(malformedData)

    XCTAssertEqual(items.count, 1)
    XCTAssertNotNil(items[0].pubDate, "Should use current date for invalid format")
  }

  // MARK: - Enclosure Tests

  func testParsingRSSWithEnclosures() async throws {
    let data = try RSSParserTestHelper.loadTestXML("RSSWithEnclosures")

    do {
      let items = try await parser.parse(data)
      XCTAssertEqual(items.count, 1)

      let item = items[0]
      XCTAssertNotNil(item.enclosure)
      XCTAssertEqual(item.enclosure?.url.absoluteString, "https://example.com/media.mp3")
      XCTAssertEqual(item.enclosure?.type, "audio/mpeg")
      XCTAssertEqual(item.enclosure?.length, 123456)
    } catch {
      XCTFail("Enclosure parsing failed: \(error)")
    }
  }

  /// malformed enclosure attributes
  func testParsingRSSWithMalformedEnclosures() async throws {
    let data = try RSSParserTestHelper.loadTestXML("RSSWithMalformedEnclosures")

    do {
      let items = try await parser.parse(data)
      XCTAssertEqual(items.count, 1)
      XCTAssertNil(items[0].enclosure, "Should ignore invalid enclosures")
    } catch {
      XCTFail("Malformed enclosure handling failed: \(error)")
    }
  }

  // MARK: - Network Tests

  func testFetchRSSFeedFromURLSuccess() async throws {
    let testData = try RSSParserTestHelper.loadTestXML("ValidRSS")
    let mockService = RSSParserTestHelper.mockNetworkService(withData: testData)
    let mockRepository = RSSRepositoryImpl(networkService: mockService, rssParser: parser)

    let url = URL(string: "https://example.com/feed.xml")!
    let items = try await mockRepository.fetchRSSFeed(from: url)

    XCTAssertEqual(items.count, 2)
  }

  func testFetchRSSFeedFromURLNetworkFailure() async throws {
    let networkError = URLError(.notConnectedToInternet)
    let url = URL(string: "https://example.com/feed.xml")!

    let config = RSSParserTestHelper.mockURLSessionConfiguration { _ in
      throw networkError
    }

    let session = URLSession(configuration: config)
    let mockService = DefaultNetworkService(session: session)
    let mockRepository = RSSRepositoryImpl(networkService: mockService, rssParser: parser)

    do {
      _ = try await mockRepository.fetchRSSFeed(from: url)
      XCTFail("Should throw network error")
    } catch let error as RSSError {
      if case .networkError(let underlying, _) = error {
        XCTAssertEqual((underlying as? URLError)?.code, networkError.code)
      } else {
        XCTFail("Unexpected error type")
      }
    }
  }

  // MARK: - Concurrency Tests

  /// concurrent parsing to ensure thread safety
  func testConcurrentParsing() async throws {
    let data = try RSSParserTestHelper.loadTestXML("ValidRSS")

    async let parse1 = parser.parse(data)
    async let parse2 = parser.parse(data)
    async let parse3 = parser.parse(data)

    let results = try await [parse1, parse2, parse3]
    XCTAssertEqual(results.count, 3)

    for items in results {
      XCTAssertEqual(items.count, 2)
    }
  }

  // MARK: - Performance Tests

  /// performance with large feed
  func testParsingLargeRSSFeed() async throws {
    let data = try RSSParserTestHelper.loadTestXML("LargeRSS")

    measure {
      Task {
        do {
          let items = try await parser.parse(data)
          XCTAssertEqual(items.count, 200)
        } catch {
          XCTFail("Large feed parsing failed: \(error)")
        }
      }
    }
  }

  /// heavy load
  func testParsingUnderLoad() async throws {
    let data = try RSSParserTestHelper.loadTestXML("ValidRSS")
    let iterations = 100

    measure {
      Task {
        async let parses = (0 ..< iterations).asyncMap { _ in
          try await self.parser.parse(data)
        }

        do {
          let results = try await parses
          XCTAssertEqual(results.count, iterations)
        } catch {
          XCTFail("Load test failed: \(error)")
        }
      }
    }
  }
}

package extension Collection {
  func asyncMap<T>(
    _ transform: (Element) async throws -> T
  ) async rethrows -> [T] {
    var values = [T]()
    for element in self {
      try await values.append(transform(element))
    }
    return values
  }
}
