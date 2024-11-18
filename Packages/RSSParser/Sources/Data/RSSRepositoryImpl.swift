//
//  RSSRepositoryImpl.swift
//
//
//  Created by NSFuntik on 11/18/24.
//

import Domain
import Foundation
import OSLog

/// A concrete implementation of the `RSSRepository` protocol that fetches and parses RSS feeds.
public final class RSSRepositoryImpl: RSSRepository {
  private let networkService: NetworkService
  private let rssParser: RSSParser
  private var cache: [URL: [RSSItem]] = [:]
  private let logger = Logger(subsystem: "com.rssparser.rssrepository", category: "RSSRepository")

  /// Initializes a new instance of `RSSRepositoryImpl`.
  ///
  /// - Parameters:
  ///   - networkService: The network service used for fetching data.
  ///   - rssParser: The parser used for parsing the fetched RSS data.
  public init(
    networkService: NetworkService,
    rssParser: RSSParser
  ) {
    self.networkService = networkService
    self.rssParser = rssParser
  }

  /// Fetches the RSS feed from the specified URL.
  ///
  /// This method retrieves the data from the provided URL and parses it into an array of `RSSItem`.
  /// If the data has been previously fetched, the cached data is returned.
  ///
  /// - Parameter url: The URL from which to fetch the RSS feed.
  /// - Returns: An array of `RSSItem` parsed from the fetched data.
  /// - Throws: An error if the fetch or parsing fails.
  public func fetchRSSFeed(
    from url: URL,
    filter: ((RSSItem) -> Bool)? = nil
  ) async throws -> [RSSItem] {
    if let cachedItems = cache[url] {
      logger.info("Returning cached items for URL: \(url.absoluteString)")
      return applyFilter(cachedItems, filter: filter)
    }

    logger.info("Fetching RSS feed from URL: \(url.absoluteString)")
    do {
      let data = try await networkService.fetchData(from: url)
      let items = try await rssParser.parse(data)
      cache[url] = items
      logger.info("Successfully fetched and cached \(items.count) items from URL: \(url.absoluteString)")
      return applyFilter(items, filter: filter)
    } catch {
      logger.error("Error fetching or parsing RSS feed: \(error.localizedDescription)")
      throw error
    }
  }

  /// Helper for filter
  private func applyFilter(
    _ items: [RSSItem],
    filter: ((RSSItem) -> Bool)?
  ) -> [RSSItem] {
    guard let filter = filter else { return items }
    return items.filter(filter)
  }

  /// Clears the cached data for a specific URL.
  ///
  /// - Parameter url: The URL whose cache should be cleared.
  public func clearCache(for url: URL) {
    cache[url] = nil
    logger.info("Cache cleared for URL: \(url.absoluteString)")
  }

  /// Clears the entire cache.
  public func clearAllCache() {
    cache.removeAll()
    logger.info("All cache cleared.")
  }
}
