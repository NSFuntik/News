//
//  NetworkService.swift
//  RSSParser
//
//  Created by NSFuntik on 11/18/24.
//
import Foundation

/// A protocol that defines a service for fetching data from a given URL
@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
public protocol NetworkService: Sendable {
  /// Asynchronously fetches data from the specified URL
  /// - Parameter url: The URL from which to fetch data
  /// - Throws: An error if the data could not be fetched or a bad server response was received
  /// - Returns: The fetched data
  func fetchData(from url: URL) async throws -> Data
}

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
public actor DefaultNetworkService: NetworkService {
  private let session: URLSession
  private var activeTasks: Set<URLSessionTask> = []
  /// Initializes a new instance of `DefaultNetworkService`
  /// - Parameter session: The URLSession to use for network requests. Defaults to the shared session
  public init(session: URLSession = .shared) {
    self.session = session
  }

  /// Asynchronously fetches data from the specified URL.
  ///
  /// This method performs a network request to the provided URL using the
  /// associated `URLSession`. It checks for a valid HTTP response and ensures
  /// the response status code is within the successful range (200-299).
  /// If any issues occur during the fetch, it throws an appropriate
  /// `RSSError`.
  ///
  /// - Parameter url: The URL from which to fetch data.
  /// - Throws: An error if the data could not be fetched or if the response
  ///           indicates a failure (i.e., status code not in the range 200-299).
  /// - Returns: The fetched data if the request is successful.
  public func fetchData(from url: URL) async throws -> Data {
    do {
      let (data, response) = try await session.data(from: url)
      guard let httpResponse = response as? HTTPURLResponse else {
        throw RSSError.networkError(
          underlying: URLError(.badServerResponse),
          statusCode: nil
        )
      }
      guard (200 ... 299).contains(httpResponse.statusCode) else {
        throw RSSError.networkError(
          underlying: URLError(.badServerResponse),
          statusCode: httpResponse.statusCode
        )
      }
      return data
    } catch let error as RSSError {
      throw error
    } catch {
      throw RSSError.networkError(
        underlying: error,
        statusCode: nil
      )
    }
  }
}
