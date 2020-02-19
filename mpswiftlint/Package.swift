// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "mpswiftlint",
    products: [
        .executable(name: "mpswiftlint", targets: ["mpswiftlint"]),
        .library(name: "MPSwiftLintFramework", targets: ["MPSwiftLintFramework"])
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/SourceKitten.git", from: "0.26.0")
    ],
    targets: [
        .target(
            name: "mpswiftlint",
            dependencies: [
                "MPSwiftLintFramework"
            ]
        ),
        .target(
            name: "MPSwiftLintFramework",
            dependencies: [
                "SourceKittenFramework"
            ]
        ),
        .testTarget(
            name: "MPSwiftLintTests",
            dependencies: [
                "MPSwiftLintFramework"
            ]
        ),
    ]
)
