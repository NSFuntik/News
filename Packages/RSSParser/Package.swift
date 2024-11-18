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
      targets: ["Data", "Domain"]
    ),
  ],
  targets: [
    .target(
      name: "Domain",
      path: "Sources/Domain"
    ),
    .target(
      name: "Data",
      dependencies: ["Domain"],
      path: "Sources/Data"
    ),
    .testTarget(
      name: "Tests",
      dependencies: ["Data", "Domain"],
      path: "Tests",
      resources: [
        .process("Resources")
      ]
    ),
  ]
)
