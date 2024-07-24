// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SimpleAuthedNetworking",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SimpleAuthedNetworking",
            targets: ["SimpleAuthedNetworking"]),
    ],
    dependencies: [
        .package(url: "https://github.com/samanthagatt/SimpleNetworking", exact: "0.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SimpleAuthedNetworking",
            dependencies: ["SimpleNetworking"]),
        .testTarget(
            name: "SimpleAuthedNetworkingTests",
            dependencies: ["SimpleAuthedNetworking"]),
    ]
)
