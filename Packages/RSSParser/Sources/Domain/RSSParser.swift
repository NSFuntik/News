//
//  RSSParser.swift
//
//
//  Created by NSFuntik on 11/18/24.
//
import Foundation

/// Protocol defining the RSSParser capabilities.
public protocol RSSParser {
  /// Parses the given RSS data into an array of `RSSItem`.
  /// - Parameter data: The data representing the RSS feed.
  /// - Returns: An array of `RSSItem` instances.
  /// - Throws: An error if parsing fails or the data is invalid.
  func parse(_ data: Data) async throws -> [RSSItem]

  /// Parses the RSS feed from a given URL.
  /// - Parameter url: The URL of the RSS feed to fetch and parse.
  /// - Returns: An array of `RSSItem` instances.
  /// - Throws: An error if network error occurs or parsing fails.
  func parse(url: URL) async throws -> [RSSItem]

  /// Fetches the RSS feed from the specified URL and returns parsed items.
  /// - Parameter url: The URL of the RSS feed to fetch.
  /// - Returns: An array of `RSSItem` instances.
  /// - Throws: An error if fetching or parsing fails.
  func fetchRSSFeed(from url: URL) async throws -> [RSSItem]
}
