//
//  RSSCacheImpl.swift
//  RSSParser
//
//  Created by NSFuntik on 11/18/24.
//
import RSSDomain
import Foundation
import OSLog

public actor RSSCacheImpl: RSSCache {
  private struct CacheEntry {
    let items: [RSSItem]
    let timestamp: Date
    let size: Int
    let configuration: RSSCacheConfiguration

    var isExpired: Bool {
      Date().timeIntervalSince(timestamp) > configuration.itemExpirationInterval
    }
  }

  private var entries: [URL: CacheEntry] = [:]
  private var totalSize: Int = 0
  public let configuration: RSSCacheConfiguration
  private let logger = Logger(subsystem: "com.rssparser.cache", category: "RSSCache")

  public init(configuration: RSSCacheConfiguration = RSSCacheConfiguration()) {
    self.configuration = configuration
  }

  public func get(for url: URL) async -> [RSSItem]? {
    guard let entry = entries[url] else {
      return nil
    }

    if entry.isExpired {
      entries.removeValue(forKey: url)
      totalSize -= entry.size
      return nil
    }

    return entry.items
  }

  public func set(_ items: [RSSItem], for url: URL) async {
    let size = estimateSize(for: items)
    // swiftformat:disable:next redundantSelf
    guard size <= configuration.maxCacheSize else {
      logger.warning(
        "Cache entry size exceeds maximum cache size: \(size) > \(self.configuration.maxCacheSize)"
      )
      return
    }

    while totalSize + size > configuration.maxCacheSize {
      evictLRU()
    }

    let entry = CacheEntry(
      items: items,
      timestamp: Date(),
      size: size,
      configuration: configuration
    )

    if let oldEntry = entries[url] {
      totalSize -= oldEntry.size
    }

    entries[url] = entry
    totalSize += size

    logger.debug("Cache entry set for URL: \(url.absoluteString), size: \(size)")
  }

  public func remove(for url: URL) async {
    if let entry = entries[url] {
      totalSize -= entry.size
      entries.removeValue(forKey: url)
      logger.debug("Cache entry removed for URL: \(url.absoluteString)")
    }
  }

  public func removeAll() async {
    entries.removeAll()
    totalSize = 0
    logger.debug("Cache cleared")
  }

  private func evictLRU() {
    guard let oldestURL = entries
      .min(by: { $0.value.timestamp < $1.value.timestamp })?
      .key
    else { return }

    if let entry = entries[oldestURL] {
      totalSize -= entry.size
      entries.removeValue(forKey: oldestURL)
    }
  }

  private func estimateSize(for items: [RSSItem]) -> Int {
    return items.reduce(0) { total, item in
      let titleSize = item.title.utf8.count
      let descriptionSize = item.description.utf8.count
      let contentSize = item.content?.utf8.count ?? 0
      let linkSize = item.link.absoluteString.utf8.count
      let authorSize = item.author?.utf8.count ?? 0
      let categoriesSize = item.categories.reduce(0) { $0 + $1.utf8.count }

      return total
        + titleSize
        + descriptionSize
        + contentSize
        + linkSize
        + authorSize
        + categoriesSize
    }
  }
}
