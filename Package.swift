// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "ios-filemanagement",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "FileManagementModule",
            targets: ["FileManagementModule"]
        ),
    ],
    dependencies: [
        .package(url: "git@gitlab.services.mts.ru:membrana-ios/darwin-perdux.git", from: "3.3.1"),
        .package(url: "git@gitlab.services.mts.ru:membrana-ios/darwin-restclient.git", from: "0.10.0"),
        .package(url: "git@gitlab.services.mts.ru:membrana-ios/darwin-foundationplus.git", from: "2.0.0"),
        .package(url: "git@gitlab.services.mts.ru:membrana-ios/swift-stdlibplus.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "FileManagementModule",
            dependencies: [
                .product(name: "Perdux", package: "darwin-perdux"),
                .product(name: "RestClient", package: "darwin-restclient"),
                .product(name: "FoundationPlus", package: "darwin-foundationplus"),
                .product(name: "SwiftPlus", package: "swift-stdlibplus"),
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "FileManagementModuleTests",
            dependencies: ["FileManagementModule"],
            path: "Tests"
        ),
    ]
)
