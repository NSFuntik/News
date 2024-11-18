//
//  RSSCache.swift
//  RSSParser
//
//  Created by NSFuntik on 11/18/24.
//
import Foundation

/// A configuration struct for the RSS cache system.
public struct RSSCacheConfiguration: Sendable {
  /// The maximum size of the cache in bytes.
  public let maxCacheSize: Int
  /// The time interval after which cached items expire.
  public let itemExpirationInterval: TimeInterval
  /// Initializes an `RSSCacheConfiguration` instance with the specified parameters.
  ///
  /// - Parameters:
  ///   - maxCacheSize: The maximum size of the cache in bytes. Default is 50 MB.
  ///   - itemExpirationInterval: The time interval after which cached items expire. Default is 30 minutes.
  public init(
    maxCacheSize: Int = 50 * 1024 * 1024,
    itemExpirationInterval: TimeInterval = 60 * 30
  ) {
    self.maxCacheSize = maxCacheSize
    self.itemExpirationInterval = itemExpirationInterval
  }
}

/// A protocol that defines the requirements for an RSS cache.
public protocol RSSCache: Sendable {
  /// Retrieves cached RSS items for a given URL.
  ///
  /// - Parameter url: The URL for which to retrieve cached items.
  /// - Returns: An array of `RSSItem` if items are found, otherwise `nil`.
  func get(for url: URL) async -> [RSSItem]?
  /// Caches the given RSS items for a specific URL.
  ///
  /// - Parameters:
  ///   - items: The array of `RSSItem` to be cached.
  ///   - url: The URL for which to cache the items.
  func set(_ items: [RSSItem], for url: URL) async
  /// Removes cached items for a specific URL.
  ///
  /// - Parameter url: The URL for which to remove cached items.
  func remove(for url: URL) async
  /// Removes all cached items.
  func removeAll() async
  /// The configuration settings for the RSS cache.
  var configuration: RSSCacheConfiguration { get }
}
