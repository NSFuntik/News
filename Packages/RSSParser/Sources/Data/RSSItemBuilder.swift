//
//  RSSItemBuilder.swift
//
//
//  Created by NSFuntik on 11/18/24.
//
// swiftformat:disable redundantSelf
import RSSDomain
import Foundation
import os.log

/// A builder class for constructing `RSSItem` instances.
///
/// This class allows the user to set properties that define the content of the RSS item,
/// including the GUID, title, description, link, publication date, author, categories,
/// content, and enclosure.
package final class RSSItemBuilder {
  package var guid: String = ""
  package var title: String = ""
  package var description: String = ""
  package var linkString: String = ""
  package var pubDateString: String = ""
  package var author: String = ""
  package var categories: [String] = []
  package var content: String?
  package var enclosure: RSSEnclosure?

  private let logger = Logger(subsystem: "com.rssparser.builder", category: "RSSItemBuilder")

  /// Builds an `RSSItem` using the properties set on the builder.
  func build(dateFormatters: [DateFormatter]) -> RSSItem? {
    let id = guid.isEmpty ? linkString : guid

    guard !id.isEmpty, !title.isEmpty else {
      return nil
    }

    guard let link = URL(string: linkString) else {
      return nil
    }

    let pubDate = dateFormatters.compactMap { $0.date(from: pubDateString) }.first

    return RSSItem(
      id: id,
      title: title,
      description: description,
      link: link,
      pubDate: pubDate ?? Date(),
      author: author,
      categories: categories,
      content: content?.isEmpty == true ? nil : content,
      enclosure: enclosure
    )
  }
}
