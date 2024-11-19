//
//  NewsApp.swift
//  News
//
//  Created by Dmitry Mikhailov on 10.11.2024.
//

import NewsFeature
import SwiftUI

@main
struct NewsApp: App {
  // Создаем экземпляр координатора как источник истины для навигации
  @StateObject private var coordinator: FeatureCoordinator = .main

  // Инициализация зависимостей приложения
  init() {
    DI.Container.setupNewsFeature()
  }

  var body: some Scene {
    WindowGroup {
      // Используем NewsCoordinator для навигации

      coordinator.view(for: .newsList)
        .environmentObject(coordinator)
    }
  }
}
