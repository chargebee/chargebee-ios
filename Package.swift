// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Chargebee",
    platforms: [.iOS(.v9)],
    products: [
        .library(name: "Chargebee", targets: ["Chargebee"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Chargebee",
            dependencies: [],
            path: "Chargebee",
            exclude: [],
            sources: ["Classes"],
            resources: [.process("Assets")])
    ]
)
