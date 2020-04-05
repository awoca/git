// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Git",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "Git",
            targets: ["Git"])
    ],
    targets: [
        .target(
            name: "Git",
            path: "Sources"),
        .testTarget(
            name: "Tests",
            dependencies: ["Git"],
            path: "Tests")
    ]
)
