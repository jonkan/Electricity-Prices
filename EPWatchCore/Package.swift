// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "EPWatchCore",
    defaultLocalization: "en",
    platforms: [
        .iOS("17.0"),
        .watchOS("10.0")
    ],
    products: [
        .library(
            name: "EPWatchCore",
            targets: ["EPWatchCore"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/CoreOffice/XMLCoder.git", from: "0.14.0"),
        .package(url: "https://github.com/DaveWoodCom/XCGLogger.git", from: "7.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.6.1")
    ],
    targets: [
        .target(
            name: "EPWatchCore",
            dependencies: [
                "XMLCoder",
                "XCGLogger",
                "Alamofire"
            ],
            path: "EPWatchCore",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "EPWatchCoreTests",
            dependencies: ["EPWatchCore"],
            path: "EPWatchCoreTests",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
