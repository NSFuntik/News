// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "NewsFeature",
  platforms: [
    .iOS(.v15),
    .macCatalyst(.v15),
    .macOS(.v13),
  ],
  products: [
    .library(
      name: "NewsFeature",
      targets: ["NewsFeature"]
    ),
  ],
  dependencies: [
    .package(path: "../RSSParser"),
    .package(path: "../SwiftModernArchitecture"),
    .package(path: "../SwiftToolkit"),
  ],
  targets: [
    .target(
      name: "NewsFeature",
      dependencies: [
        "NewsDomain",
        .product(name: "RSSParser", package: "RSSParser"),
        .product(name: "DI", package: "SwiftToolkit"),
        .product(name: "Coordinator", package: "SwiftToolkit"),
        .product(name: "CoreDatabase", package: "SwiftToolkit"),
        .product(name: "CoreArch", package: "SwiftModernArchitecture"),
      ]
    ),
    .target(
      name: "NewsDomain",
      dependencies: [
        .product(name: "CoreArch", package: "SwiftModernArchitecture"),
      ],
      path: "Sources/Domain"
    ),
    .target(
      name: "NewsData",
      dependencies: [
        "NewsDomain",
        .product(name: "CoreDomain", package: "SwiftModernArchitecture"),
      ],
      path: "Sources/Data"
    ),
    .target(
      name: "NewsInfrastructure",
      dependencies: [
        "NewsDomain",
        "NewsData",
        .product(name: "CoreInfrastructure", package: "SwiftModernArchitecture"),
      ],
      path: "Sources/Infrastructure"
    ),
    .target(
      name: "NewsPresentation",
      dependencies: [
        "NewsDomain",
        "NewsFeature",
        .product(name: "RSSParser", package: "RSSParser"),
        .product(name: "CorePresentation", package: "SwiftModernArchitecture"),
      ],
      path: "Sources/Presentation"
    ),
    // .testTarget(name: "NewsTests", dependencies: ["NewsData", "NewsDomain"]),
  ]
)
