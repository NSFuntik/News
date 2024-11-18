//
//  RSSParserImpl.swift
//
//  Created by NSFuntik on 11/18/24.
//

import Domain
import Foundation
import os.log

/// A class that implements an RSS parser conforming to `RSSParser` protocol,
/// designed to handle parsing of RSS feeds using XML parsing techniques.
public final class RSSParserImpl: RSSParser {
  private let configuration: RSS.Configuration
  private let dateFormatters: [DateFormatter]
  private let logger: RSSLogger

  public init(configuration: RSS.Configuration = .init()) {
    self.configuration = configuration
    self.dateFormatters = Self.configureDateFormatter(for: configuration)
    self.logger = RSSLogger()
    logger.info("RSSParser initialized with configuration: bufferSize=\(configuration.bufferSize)")
  }

  private class func configureDateFormatter(for configuration: RSS.Configuration) -> [DateFormatter] {
    return RSS.DateFormat.patterns.map { format in
      let formatter = DateFormatter()
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.dateFormat = format
      return formatter
    }
  }

  public func parse(_ data: Data) async throws -> [RSSItem] {
    let signpostID = logger.beginInterval("parse")
    defer { logger.endInterval("parse", signpostID) }

    guard !data.isEmpty else {
      logger.error("Empty data provided")
      throw RSSError.emptyData
    }

    logger.info("Data size: \(data.count) bytes")

    let delegate = RSSParserDelegate(
      dateFormatters: dateFormatters,
      logger: logger,
      bufferSize: configuration.bufferSize
    )

    let parser = XMLParser(data: data)
    parser.delegate = delegate

    let success = parser.parse()

    if success {
      let items = delegate.items
      if items.isEmpty {
        logger.error("No items found in parsed data")
        throw RSSError.emptyData
      }
      logger.info("Successfully parsed \(items.count) items")
      return items
    } else if let error = parser.parserError {
      logger.error("Parsing failed", error: error)
      throw RSSErrorHandler.extractParsingError(error)
    } else {
      logger.error("Invalid data format")
      throw RSSError.invalidData(reason: "Unknown parsing error")
    }
  }

  /// Parses the RSS feed from a given URL.
  public func parse(url: URL) async throws -> [RSSItem] {
    let signpostID = logger.beginInterval("parseURL")
    defer { logger.endInterval("parseURL", signpostID) }

    logger.info("Starting parse from URL: \(url.absoluteString)")

    do {
      let (data, response) = try await URLSession.shared.data(from: url)

      if let error = RSSErrorHandler.handleNetworkResponse(response, error: nil) {
        logger.error("Network error", error: error)
        throw error
      }

      logger.info("Successfully fetched data from URL: \(url.absoluteString), size: \(data.count) bytes")
      return try await parse(data)
    } catch let error as RSSError {
      throw error
    } catch {
      logger.error("Network error", error: error)
      throw RSSError.networkError(underlying: error, statusCode: nil)
    }
  }

  /// Fetches the RSS feed from the specified URL
  /// - Returns: parsed items.
  public func fetchRSSFeed(from url: URL) async throws -> [RSSItem] {
    return try await parse(url: url)
  }
}

private final class RSSParserDelegate: NSObject, XMLParserDelegate {
  private let dateFormatters: [DateFormatter]
  private let logger: RSSLogger
  private let bufferSize: Int

  private var currentElement = ""
  private var currentItem: RSSItemBuilder?
  private var textBuffer = ""
  private var isInItem = false

  private(set) var items: [RSSItem] = []

  init(dateFormatters: [DateFormatter], logger: RSSLogger, bufferSize: Int) {
    self.dateFormatters = dateFormatters
    self.logger = logger
    self.bufferSize = bufferSize
    super.init()
  }

  func parser(
    _ parser: XMLParser,
    didStartElement elementName: String,
    namespaceURI: String?,
    qualifiedName qName: String?,
    attributes attributeDict: [String: String] = [:]
  ) {
    currentElement = elementName.lowercased()

    switch currentElement {
    case RSS.Tag.item.rawValue:
      isInItem = true
      currentItem = RSSItemBuilder()
      logger.debug("Started parsing new item")

    case RSS.Tag.enclosure.rawValue where isInItem:
      if let urlString = attributeDict["url"],
         let url = URL(string: urlString),
         let type = attributeDict["type"],
         let lengthString = attributeDict["length"],
         let length = Int64(lengthString) {
        currentItem?.enclosure = RSSEnclosure(url: url, type: type, length: length)
        logger.debug("Added enclosure: \(url)")
      }

    default:
      break
    }

    textBuffer = ""
  }

  func parser(_ parser: XMLParser, foundCharacters string: String) {
    if isInItem {
      textBuffer += string
    }
  }

  func parser(
    _ parser: XMLParser,
    didEndElement elementName: String,
    namespaceURI: String?,
    qualifiedName qName: String?
  ) {
    let element = elementName.lowercased()
    let content = textBuffer.trimmingCharacters(in: .whitespacesAndNewlines)

    if element == RSS.Tag.item.rawValue {
      if let item = currentItem?.build(dateFormatters: dateFormatters) {
        items.append(item)
        logger.debug("Completed item: \(item.title)")
      }
      isInItem = false
      currentItem = nil
      return
    }

    guard isInItem else { return }

    switch RSS.Tag(rawValue: element) {
    case .title:
      currentItem?.title = content
      logger.debug("Added title: \(content)")

    case .description:
      currentItem?.description = content

    case .link:
      currentItem?.linkString = content

    case .guid:
      currentItem?.guid = content

    case .pubDate:
      currentItem?.pubDateString = content

    case .author:
      currentItem?.author = content

    case .category:
      if !content.isEmpty {
        currentItem?.categories.append(content)
      }

    case .content:
      currentItem?.content = content.isEmpty ? nil : content

    default:
      break
    }

    textBuffer.removeAll(keepingCapacity: true)
  }

  func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
    logger.error("XML parsing error", error: parseError)
  }
}
