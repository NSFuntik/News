// import CoreDatabase

@_exported import DI
import Foundation
import os.log

import RSSData
import RSSDomain

// import NewsData

// MARK: - DI Keys

public extension DI {
  static let rssParser = Key<RSSParser>()
  static let logger = Key<Logger>()

  // public static let database = Key<Database>()

  // Core Services
//  public static let database = Key<Database>()
//  public static let networkService = Key<NetworkService>()
//
//  // RSS Services
//  public static let rssParser = Key<RSSParser>()
//  public static let rssFeedService = Key<FeedService>()
//  public static let rssNewsDataSource = Key<RSSNewsDataSource>()
//
//  // Repositories
//  public static let newsRepository = Key<NewsRepository>()
//  public static let settingsRepository = Key<SettingsRepository>()
//
//  // Use Cases
//  public static let fetchNewsUseCase = Key<FetchNewsUseCase>()
//  public static let markAsReadUseCase = Key<MarkAsReadUseCase>()
//  public static let toggleFavoriteUseCase = Key<ToggleFavoriteUseCase>()
//  public static let favoritesUseCase = Key<FavoritesUseCase>()
//  public static let settingsUseCase = Key<SettingsUseCase>()
//
//  // View Models
//  public static let newsListViewModel = Key<NewsListViewModel>()
//  public static let newsDetailViewModel = Key<NewsDetailViewModel>()
//  public static let favoritesViewModel = Key<FavoritesViewModel>()
//  public static let settingsViewModel = Key<SettingsViewModel>()
//  public static let searchViewModel = Key<SearchViewModel>()
//
//  // System Services
//  public static let backgroundTaskManager = Key<BackgroundTaskManager>()
//  public static let notificationManager = Key<NotificationManager>()
//  public static let networkMonitor = Key<NetworkMonitor>()
}

// MARK: - Container Extensions

public extension DI.Container {
  enum Lifetime {
    case transient
    case singleton
  }

  static func setupNewsFeature() {
    setupInfrastructure()
    setupRepositories()
//    setupUseCases()
    setupViewModels()
    setupSystemServices()
  }

  private static func setupInfrastructure() {
    // Core Services
    register(DI.logger) {
      Logger(subsystem: "com.app.news", category: "Default")
    }

//    register(DI.database, lifetime: .singleton) {
//      Database(
//        storeDescriptions: [
//          .localData(),
//          .cloudWithShare("NewDB", identifier: "iCloud.com.app.news"),
//        ],
//        modelBundle: .main,
//        logger: resolve(DI.logger))
//    }

    // register(DI.networkService, lifetime: .singleton) {
    //   URLSessionNetworkService(
    //     config: .default,
    //     logger: resolve(DI.logger))
    // }

    // RSS Services
    register(DI.rssParser) {
      RSSParserImpl(configuration: RSS.Configuration())
    }

    // register(DI.rssFeedService) {
    //   DefaultFeedService(
    //     networkService: resolve(DI.networkService),
    //     parser: resolve(DI.rssParser),
    //     cache: DefaultFeedCache(),
    //     logger: resolve(DI.logger))
    // }

    // register(DI.rssNewsDataSource) {
    //   RSSNewsDataSource(
    //     feedService: resolve(DI.rssFeedService),
    //     logger: resolve(DI.logger))
    // }
  }

  private static func setupRepositories() {
    //   register(DI.newsRepository) {
    //     CoreDataNewsRepository(
    //       database: resolve(DI.database),
    //       networkService: resolve(DI.networkService),
    //       rssDataSource: resolve(DI.rssNewsDataSource),
    //       logger: resolve(DI.logger))
    //   }

    //   register(DI.settingsRepository, lifetime: .singleton) {
    //     UserDefaultsSettingsRepository(
    //       logger: resolve(DI.logger)
    //     )
    //   }
    // }

    // private static func setupUseCases() {
    //   register(DI.fetchNewsUseCase) {
    //     DefaultFetchNewsUseCase(
    //       repository: resolve(DI.newsRepository),
    //       logger: resolve(DI.logger))
    //   }

    //   register(DI.markAsReadUseCase) {
    //     DefaultMarkAsReadUseCase(
    //       repository: resolve(DI.newsRepository),
    //       logger: resolve(DI.logger))
    //   }

    //   register(DI.toggleFavoriteUseCase) {
    //     DefaultToggleFavoriteUseCase(
    //       repository: resolve(DI.newsRepository),
    //       logger: resolve(DI.logger))
    //   }

    //   register(DI.favoritesUseCase) {
    //     DefaultFavoritesUseCase(
    //       repository: resolve(DI.newsRepository),
    //       logger: resolve(DI.logger))
    //   }

    //   register(DI.settingsUseCase) {
    //     DefaultSettingsUseCase(
    //       repository: resolve(DI.settingsRepository),
    //       logger: resolve(DI.logger))
    //   }
  }

  private static func setupViewModels() {
    // register(DI.newsListViewModel) {
    //   NewsListViewModel(
    //     fetchNewsUseCase: resolve(DI.fetchNewsUseCase),
    //     markAsReadUseCase: resolve(DI.markAsReadUseCase),
    //     toggleFavoriteUseCase: resolve(DI.toggleFavoriteUseCase),
    //     networkMonitor: resolve(DI.networkMonitor),
    //     logger: resolve(DI.logger))
    // }

    // register(DI.newsDetailViewModel) {
    //   NewsDetailViewModel(
    //     markAsReadUseCase: resolve(DI.markAsReadUseCase),
    //     toggleFavoriteUseCase: resolve(DI.toggleFavoriteUseCase),
    //     logger: resolve(DI.logger))
    // }

    // register(DI.favoritesViewModel) {
    //   FavoritesViewModel(
    //     favoritesUseCase: resolve(DI.favoritesUseCase),
    //     logger: resolve(DI.logger))
    // }

    // register(DI.settingsViewModel) {
    //   SettingsViewModel(
    //     settingsUseCase: resolve(DI.settingsUseCase),
    //     logger: resolve(DI.logger))
    // }

    // register(DI.searchViewModel) {
    //   SearchViewModel(
    //     fetchNewsUseCase: resolve(DI.fetchNewsUseCase),
    //     logger: resolve(DI.logger))
    // }
  }

  private static func setupSystemServices() {
    // register(DI.backgroundTaskManager, lifetime: .singleton) {
    //   DefaultBackgroundTaskManager(
    //     newsRepository: resolve(DI.newsRepository),
    //     notificationManager: resolve(DI.notificationManager),
    //     logger: resolve(DI.logger))
    // }

    // register(DI.notificationManager, lifetime: .singleton) {
    //   NotificationManager(logger: resolve(DI.logger))
    // }

    // register(DI.networkMonitor, lifetime: .singleton) {
    //   NetworkMonitor(logger: resolve(DI.logger))
    // }
  }
}
