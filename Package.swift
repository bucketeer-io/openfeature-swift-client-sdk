// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BucketeerOpenFeatureProvider",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "BucketeerOpenFeature",
            targets: ["BucketeerOpenFeature"]
        )
    ],
    dependencies: [
        // OpenFeature
        .package(url: "git@github.com:open-feature/swift-sdk.git", from: "0.2.1"),
        .package(url: "git@github.com/bucketeer-io/ios-client-sdk.git", from: "2.2.1")
    ],
    targets: [
        .target(
            name: "BucketeerOpenFeature",
            dependencies: [
                .product(name: "OpenFeature", package: "swift-sdk"),
                .product(name: "Bucketeer", package: "ios-client-sdk")
            ],
            path: "./BucketeerOpenFeature",
            resources: [.process("PrivacyInfo.xcprivacy")]),
        .testTarget(
            name: "BucketeerOpenFeatureTests",
            dependencies: ["BucketeerOpenFeature"],
            path: "./BucketeerOpenFeatureTests"
        )
    ]
)
