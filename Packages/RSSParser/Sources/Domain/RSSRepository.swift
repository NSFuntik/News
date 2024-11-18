//
//  RSSRepository.swift
//
//
//  Created by NSFuntik on 11/18/24.
//

import Foundation

/// Protocol defining the interface for fetching and caching RSS feed data.

public protocol RSSRepository {
  /// Fetches an RSS feed from the specified URL.
  /// - Parameters:
  ///   - url: The URL from which to fetch the RSS feed.
  ///   - filter: Optional filter for selecting specific items.
  /// - Returns: An array of filtered RSS items.
  /// - Throws: An error if the fetch fails or the data cannot be parsed.
  func fetchRSSFeed(from url: URL, filter: ((RSSItem) -> Bool)?) async throws -> [RSSItem]

  /// Clears the cached data for a specific URL.
  /// - Parameter url: The URL whose cache should be cleared.
  func clearCache(for url: URL)
  /// Clears entire cached data for a specific URL.
  func clearAllCache()
}
