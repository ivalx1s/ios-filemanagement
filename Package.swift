// swift-tools-version: 6.0
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
        .package(url: "https://github.com/ivalx1s/darwin-relux.git", .upToNextMajor(from: "5.0.1")),
        .package(url: "https://github.com/ivalx1s/darwin-httpclient.git", .upToNextMajor(from: "3.1.1")),
        .package(url: "https://github.com/ivalx1s/darwin-foundationplus.git", .upToNextMajor(from: "2.7.0")),
        .package(url: "https://github.com/ivalx1s/swift-stdlibplus.git", .upToNextMajor(from: "2.1.0"))
    ],
    targets: [
        .target(
            name: "FileManagementModule",
            dependencies: [
                .product(name: "Relux", package: "darwin-relux"),
                .product(name: "HttpClient", package: "darwin-httpclient"),
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
