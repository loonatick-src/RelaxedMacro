// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Relaxed",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .library(
            name: "Relaxed",
            targets: ["Relaxed"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
        .package(url: "https://github.com/swiftlang/swift-syntax", "600.0.0"..<"602.0.0"),
    ],
    targets: [
        // Macro implementation using SwiftSyntax
        .macro(
            name: "RelaxedMacros",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        // Client library that exposes the macro
        .target(
            name: "Relaxed",
            dependencies: [
                "RelaxedMacros",
                .product(name: "RealModule", package: "swift-numerics"),
            ]
        ),
        .testTarget(
            name: "RelaxedTests",
            dependencies: [
                "Relaxed",
                "RelaxedMacros",
                .product(name: "RealModule", package: "swift-numerics"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
