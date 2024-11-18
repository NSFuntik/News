//
//  RSSCacheTests 2.swift
//  RSSParser
//
//  Created by NSFuntik on 11/18/24.
//

@testable import Data
@testable import Domain
import XCTest

final class RSSCacheTests: XCTestCase {
  private var cache: RSSCacheImpl!
  private var configuration: RSSCacheConfiguration!

  private func createMockRSSItems(count: Int = 2) -> [RSSItem] {
    return (0..<count).map { index in
      RSSItem(
        id: "id\(index)",
        title: "Title \(index)",
        description: "Description \(index)",
        link: URL(string: "https://example.com/\(index)")!,
        pubDate: Date(),
        content: "Content \(index)"
      )
    }
  }

  override func setUp() {
    super.setUp()
    configuration = RSSCacheConfiguration(
      maxCacheSize: 1024 * 1024,
      itemExpirationInterval: 60
    )
    cache = RSSCacheImpl(configuration: configuration)
  }

  /// Tests setting and retrieving cached items. Sets mock RSS items in the cache for a URL, retrieves them, and asserts they match the original set.
  func testSetAndGetCache() async throws {
    let url = URL(string: "https://example.com/feed")!
    let items = createMockRSSItems()
    await cache.set(items, for: url)
    let cachedItems = await cache.get(for: url)
    XCTAssertEqual(cachedItems, items)
  }

  /// For removing a specific cache entry based on the URL.
  /// It sets cache entries for two URLs, removes the cache for the first URL, and asserts the first URL cache is nil while the second URL cache remains intact.
  func testRemoveSpecificCache() async throws {
    let url1 = URL(string: "https://example.com/feed1")!
    let url2 = URL(string: "https://example.com/feed2")!

    let items1 = createMockRSSItems()
    let items2 = createMockRSSItems(count: 3)
    await cache.set(items1, for: url1)
    await cache.set(items2, for: url2)
    await cache.remove(for: url1)

    let cachedItems1 = await cache.get(for: url1)
    let cachedItems2 = await cache.get(for: url2)
    XCTAssertNil(cachedItems1)
    XCTAssertEqual(cachedItems2, items2)
  }

  ///  removes all cached entries.
  ///   asserts that both entries are removed and return nil.
  func testRemoveAllCache() async throws {
    let url1 = URL(string: "https://example.com/feed1")!
    let url2 = URL(string: "https://example.com/feed2")!

    await cache.set(createMockRSSItems(), for: url1)
    await cache.set(createMockRSSItems(count: 3), for: url2)
    await cache.removeAll()

    let cachedItems1 = await cache.get(for: url1)
    let cachedItems2 = await cache.get(for: url2)
    XCTAssertNil(cachedItems1)
    XCTAssertNil(cachedItems2)
  }

  ///  Tests cache entry expiration based on configured duration
  ///  sets a short expiration interval, waits longer than it, and checks if items have expired and are unavailable.
  func testCacheExpiration() async throws {
    let url = URL(string: "https://example.com/feed")!
    let items = createMockRSSItems()

    let shortLivedConfiguration = RSSCacheConfiguration(
      maxCacheSize: 1024 * 1024,
      itemExpirationInterval: 0.1
    )
    let shortLivedCache = RSSCacheImpl(configuration: shortLivedConfiguration)
    await shortLivedCache.set(items, for: url)

    try await Task.sleep(nanoseconds: 200000000)
    let cachedItems = await shortLivedCache.get(for: url)
    XCTAssertNil(cachedItems, "Cache items should be expired")
  }

  ///  the cache has a maximum size limit
  /// adds a lot of items to the cache, which is bigger than the limit, and makes sure that the cache doesn’t keep any of them because it’s too full.
  func testCacheSizeLimit() async throws {
    let url = URL(string: "https://example.com/feed")!
    let largeFeedItems = (0..<100).map { index in
      RSSItem(
        id: "id\(index)",
        title: String(repeating: "Large Title ", count: 1000),
        description: String(repeating: "Large Description ", count: 1000),
        link: URL(string: "https://example.com/\(index)")!,
        pubDate: Date(),
        content: String(repeating: "Large Content ", count: 1000)
      )
    }
    await cache.set(largeFeedItems, for: url)
    let cachedItems = await cache.get(for: url)
    XCTAssertNil(cachedItems, "Cache should reject items exceeding max size")
  }

  ///  multiple tasks can access the cache at the same time.
  /// It sets some items in the cache and then checks if all the tasks get the same items back.
  func testConcurrentCacheAccess() async throws {
    let url = URL(string: "https://example.com/feed")!
    let items = createMockRSSItems()
    await cache.set(items, for: url)
    let concurrentTasks = (0..<10).map { _ in
      Task {
        await cache.get(for: url)
      }
    }
    async let results = concurrentTasks.asyncMap { await $0.value }
    for result in await results {
      XCTAssertEqual(result, items)
    }
  }
}
