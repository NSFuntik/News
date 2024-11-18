//
//  RSS.swift
//  RSSParser
//
//  Created by NSFuntik on 11/18/24.
//
import Foundation
import os.log

/// Namespace for RSS parsing constants
public enum RSS {
  /// XML tag names used in RSS feeds
  public enum Tag: String, CaseIterable {
    case item
    case title
    case description
    case link
    case guid
    case pubDate = "pubdate"
    case author
    case category
    case content = "content:encoded"
    case enclosure
    // media items within the RSS feed
    case url
    case type
    case length
  }

  /// Date format patterns supported by the parser
  public enum DateFormat {
    /// A list of date format patterns that the parser can recognize
    public static let patterns = [
      "EEE, dd MMM yyyy HH:mm:ss Z",
      "EEE, dd MMM yyyy HH:mm:ss zzz",
      "yyyy-MM-dd'T'HH:mm:ssZ",
      "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
      "E, d MMM yyyy HH:mm:ss Z",
      "EEE, d MMM yy HH:mm:ss Z",
    ]
  }

  /// Configuration options for the parser
  public struct Configuration {
    /// The size of the buffer used for parsing the RSS feed
    public let bufferSize: Int
    /// The timeout duration for parsing operations
    public let parsingTimeout: TimeInterval
    /// The date formats that the parser will use for date parsing
    public let dateFormats: [String]
    /// A flag indicating whether strict parsing should be enforced
    public let strictParsing: Bool
    /// Initializes a configuration with specified options.
    /// - Parameters:
    ///   - bufferSize: The size of the buffer (default is defined in `Constants`).
    ///   - parsingTimeout: The duration to wait before timing out (default is defined in `Constants`).
    ///   - dateFormats: An array of date formats that the parser will use (defaults to `DateFormat.patterns`).
    ///   - strictParsing: A boolean indicating if strict parsing should be applied (defaults to `false`).
    public init(
      bufferSize: Int = Constants.bufferSize,
      parsingTimeout: TimeInterval = Constants.parsingTimeout,
      dateFormats: [String] = DateFormat.patterns,
      strictParsing: Bool = false
    ) {
      self.bufferSize = bufferSize
      self.parsingTimeout = parsingTimeout
      self.dateFormats = dateFormats
      self.strictParsing = strictParsing
    }
  }

  @usableFromInline
  enum Constants {
    @usableFromInline static let parsingTimeout: TimeInterval = 30
    @usableFromInline static let bufferSize = 4096
  }

  /// Structure for tracking parser performance metrics
  public struct Metrics {
    /// The time when parsing starts
    public let parseStartTime: Date
    /// The time when parsing ends
    public let parseEndTime: Date
    /// The total number of items parsed
    public let itemCount: Int
    /// The size of the data processed during parsing
    public let dataSize: Int
    /// The duration of parsing measured in seconds
    public var parsingDuration: TimeInterval {
      parseEndTime.timeIntervalSince(parseStartTime)
    }

    /// The average number of items parsed per second
    public var itemsPerSecond: Double {
      Double(itemCount) / parsingDuration
    }

    /// The average number of bytes processed per second
    public var bytesPerSecond: Double {
      Double(dataSize) / parsingDuration
    }
  }
}

extension RSS.Tag: RawRepresentable {
    public init?(rawValue: String) {
      switch rawValue {
      case "item": self = .item
      case "title": self = .title
      case "description": self = .description
      case "link": self = .link
      case "guid": self = .guid
      case "pubdate": self = .pubDate
      case "author": self = .author
      case "category": self = .category
      case "content:encoded": self = .content
      case "enclosure": self = .enclosure
      case "url": self = .url
      case "type": self = .type
      case "length": self = .length
      default: return nil
    }
  }
}
