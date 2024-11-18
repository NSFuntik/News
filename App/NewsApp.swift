//
//  NewsApp.swift
//  News
//
//  Created by Dmitry Mikhailov on 10.11.2024.
//

import SwiftUI

@main
struct NewsApp: App {
  let persistenceController = PersistenceController.shared

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}
