// swift-tools-version:5.10
import PackageDescription

let package = Package(
  name: "RSSParser",
  platforms: [
    .iOS(.v15),
    .macCatalyst(.v15),
    .macOS(.v12),

  ],
  products: [
    .library(
      name: "RSSParser",
      targets: ["RSSData"]
    ),
  ],
  targets: [
    .target(
      name: "RSSDomain",
      path: "Sources/Domain"
    ),
    .target(
      name: "RSSData",
      dependencies: ["RSSDomain"],
      path: "Sources/Data"
    ),
    .testTarget(
      name: "RSSTests",
      dependencies: ["RSSData", "RSSDomain"],
      path: "Tests",
      resources: [
        .process("Resources")
      ]
    ),
  ]
)
