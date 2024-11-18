//
//  RSSItem.swift
//
//
//  Created by NSFuntik on 11/18/24.
//
import Foundation

// MARK: - RSSItem

/// Represents a single RSS feed item
public struct RSSItem: Equatable, Identifiable, Hashable {
  public let id: String
  public let title: String
  public let description: String
  public let link: URL
  public let pubDate: Date
  public let author: String?
  public let categories: [String]
  public let content: String?
  public let enclosure: RSSEnclosure?

  public init(
    id: String,
    title: String,
    description: String,
    link: URL,
    pubDate: Date,
    author: String? = nil,
    categories: [String] = [],
    content: String? = nil,
    enclosure: RSSEnclosure? = nil
  ) {
    self.id = id
    self.title = title
    self.description = description
    self.link = link
    self.pubDate = pubDate
    self.author = author
    self.categories = categories
    self.content = content
    self.enclosure = enclosure
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(title)
    hasher.combine(link)
    hasher.combine(pubDate)
  }
}

/// Represents a media enclosure in an RSS item
public struct RSSEnclosure: Equatable, Hashable {
  public let url: URL
  public let type: String
  public let length: Int64

  /// Initializes a new `RSSEnclosure` instance.
  /// - Parameters:
  ///   - url: The URL of the enclosure
  ///   - type: The MIME type of the enclosure
  ///   - length: The length of the enclosure in bytes
  public init(url: URL, type: String, length: Int64) {
    self.url = url
    self.type = type
    self.length = length
  }
}
