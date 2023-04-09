// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CocoaSprings",
    platforms: [
        .macOS(.v10_13),
        .macCatalyst(.v13),
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "CocoaSprings",
            targets: ["CocoaSprings"])
    ],
    targets: [
        .target(
            name: "CocoaSprings",
            dependencies: [],
            path: "Sources/"),
    ]
)
