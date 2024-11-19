import Foundation

public struct News: Identifiable, Hashable, Equatable {
  public let id: String
  public let title: String
  public let content: String
  public let url: URL?
  public let imageURL: URL?
  public let publishDate: Date
  public let author: String?
  public let source: NewsSource
  public let categories: [String]
  public var isRead: Bool
  public var isFavorite: Bool

  public init(
    id: String = UUID().uuidString,
    title: String,
    content: String,
    url: URL? = nil,
    imageURL: URL? = nil,
    publishDate: Date = Date(),
    author: String? = nil,
    source: NewsSource,
    categories: [String] = [],
    isRead: Bool = false,
    isFavorite: Bool = false) {
    self.id = id
    self.title = title
    self.content = content
    self.url = url
    self.imageURL = imageURL
    self.publishDate = publishDate
    self.author = author
    self.source = source
    self.categories = categories
    self.isRead = isRead
    self.isFavorite = isFavorite
  }

}


public struct NewsSource: Identifiable, Equatable, Hashable {
  public let id: String
  public let name: String
  public let url: URL?
  public let iconURL: URL?
  public let updateInterval: TimeInterval
  public let maxItemAge: TimeInterval?

  public init(
    id: String,
    name: String,
    url: URL?,
    iconURL: URL? = nil,
    updateInterval: TimeInterval = 3600,
    maxItemAge: TimeInterval? = nil) {
    self.id = id
    self.name = name
    self.url = url
    self.iconURL = iconURL
    self.updateInterval = updateInterval
    self.maxItemAge = maxItemAge
  }
}
