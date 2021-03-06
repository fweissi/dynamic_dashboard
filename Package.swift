// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "dynamic_dashboard",
    platforms: [
       .macOS(.v10_15)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0-rc"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/twostraws/SwiftGD.git", from: "2.5.0"),
    ],
    targets: [
        .target(name: "App", dependencies: [
            .product(name: "SwiftGD", package: "SwiftGD"),
            .product(name: "Leaf", package: "leaf"),
            .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
            .product(name: "Fluent", package: "fluent"),
            .product(name: "Vapor", package: "vapor"),
        ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
