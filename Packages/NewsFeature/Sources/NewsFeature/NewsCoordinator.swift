@_exported import Coordinator
@_exported import CoreArch
import CoreDomain
import Foundation
import NewsDomain
import SwiftUI

// MARK: - NewsCoordinator

public final class FeatureCoordinator: NavigationCoordinator, ModalCoordinator {
  public static let main = FeatureCoordinator()
  private init() {}

  @Published public private(set) var currentScreen: Screen = .newsList

  // MARK: - Navigation Screens

  public enum Screen: Hashable, ScreenProtocol {
    case newsList
    // case newsDetail(News)
    // case favorites
    // case categoryNews(String)
    // case sourceNews(NewsSource)
    // case search
  }

  @ViewBuilder
  public func destination(for screen: Screen) -> some View {
    EmptyView()
    // switch screen {
    // case .newsList:
    //   NewsListView(viewModel: makeNewsListViewModel())
    // case let .newsDetail(news):
    //   NewsDetailView(
    //     viewModel: makeNewsDetailViewModel(),
    //     news: news)
    // case .favorites:
    //   FavoritesView(viewModel: makeFavoritesViewModel())
    // case let .categoryNews(category):
    //   CategoryNewsView(
    //     viewModel: makeCategoryNewsViewModel(),
    //     category: category)
    // case let .sourceNews(source):
    //   SourceNewsView(
    //     viewModel: makeSourceNewsViewModel(),
    //     source: source)
    // case .search:
    //   SearchView(viewModel: makeSearchViewModel())
    // }
  }

  // MARK: - Modal Flows

  public enum ModalFlow: Hashable, ModalProtocol {
    // case settings
    // case addSource
    // case shareNews(News)
    // case filter(FilterOptions)
    // case alert(AlertType)

    // var style: ModalStyle {
    //   switch self {
    //   case .settings:
    //     return .cover
    //   case .addSource:
    //     return .sheet
    //   case .shareNews:
    //     return .overlay
    //   case .filter:
    //     return .sheet
    //   case .alert:
    //     return .overlay
    //   }
    // }
  }

  @ViewBuilder
  public func destination(for flow: ModalFlow) -> some View {
    // switch flow {
    // case .settings:
    //   SettingsView(viewModel: makeSettingsViewModel())
    // case .addSource:
    //   AddSourceView(viewModel: makeAddSourceViewModel())
    // case let .shareNews(news):
    //   ShareSheet(news: news)
    // case let .filter(options):
    //   FilterView(
    //     viewModel: makeFilterViewModel(),
    //     options: options)
    // case let .alert(type):
    //   alertView(for: type)
    // }
    EmptyView()
  }

  // MARK: - Alert Types

  public enum AlertType: Hashable {
    public func hash(into hasher: inout Hasher) {
      hasher.combine(code)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
      rhs.hashValue == lhs.hashValue
    }

    case error(Error? = nil)
    // case deleteConfirmation(News)
    case markAllRead
    case clearCache

    public var code: Int {
      switch self {
      case .error: return 0
      case .markAllRead: return 2
      case .clearCache: return 3
      }
    }
  }

  private func alertView(for type: AlertType) -> some View {
    return EmptyView()
    // switch type {
    // case let .error(error):
    //   AlertView(
    //     title: "Error",
    //     message: error.localizedDescription,
    //     primaryButton: .default("OK"),
    //     secondaryButton: .default("Retry") {
    //       handleErrorRetry(error)
    //     })
    // case let .deleteConfirmation(news):
    //   AlertView(
    //     title: "Delete News",
    //     message: "Are you sure you want to delete '\(news.title)'?",
    //     primaryButton: .destructive("Delete") {
    //       handleNewsDelete(news)
    //     },
    //     secondaryButton: .cancel())
    // case .markAllRead:
    //   AlertView(
    //     title: "Mark All as Read",
    //     message: "Are you sure you want to mark all news as read?",
    //     primaryButton: .default("Mark All") {
    //       handleMarkAllRead()
    //     },
    //     secondaryButton: .cancel())
    // case .clearCache:
    //   AlertView(
    //     title: "Clear Cache",
    //     message: "This will delete all cached content. Continue?",
    //     primaryButton: .destructive("Clear") {
    //       handleClearCache()
    //     },
    //     secondaryButton: .cancel())
    // }
  }

  // MARK: - Error Handling

  private func handleErrorRetry(_ error: Error) {
    // Implement error retry logic
  }

  private func handleNewsDelete(_ news: News) {
    // Implement news deletion
  }

  private func handleMarkAllRead() {
    // Implement mark all as read
  }

  private func handleClearCache() {
    // Implement cache clearing
  }

  // MARK: - Navigation Helpers

//
//  public func showNewsDetail(_ news: News) {
//    show(.newsDetail(news))
//  }
//
//  public func showCategory(_ category: String) {
//    show(.categoryNews(category))
//  }
//
//  public func showSource(_ source: NewsSource) {
//    show(.sourceNews(source))
//  }
//
//  public func showError(_ error: Error) {
//    present(.alert(.error(error)))
//  }
//
//  public func showShareSheet(for news: News) {
//    present(.shareNews(news))
//  }
//
//  // MARK: - ViewModels Factory
//
//  private func makeNewsListViewModel() -> NewsListViewModel {
//    DI.resolve()
//  }
//
//  private func makeNewsDetailViewModel() -> NewsDetailViewModel {
//    DI.resolve()
//  }
//
//  private func makeFavoritesViewModel() -> FavoritesViewModel {
//    DI.resolve()
//  }
//
//  private func makeSettingsViewModel() -> SettingsViewModel {
//    DI.resolve()
//  }
//
//  private func makeAddSourceViewModel() -> AddSourceViewModel {
//    DI.resolve()
//  }
//
//  private func makeFilterViewModel() -> FilterViewModel {
//    DI.resolve()
//  }
//
//  private func makeCategoryNewsViewModel() -> CategoryNewsViewModel {
//    DI.resolve()
//  }
//
//  private func makeSourceNewsViewModel() -> SourceNewsViewModel {
//    DI.resolve()
//  }
//
//  private func makeSearchViewModel() -> SearchViewModel {
//    DI.resolve()
//  }

  // MARK: - Helper Methods

  public func show(_ screen: Screen) {
    currentScreen = screen
    // Логика навигации
  }
}
