// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FueldHk",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "FueldHk",
            targets: ["fueldHKPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", branch: "main")
    ],
    targets: [
        .target(
            name: "fueldHKPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/fueldHKPlugin"),
        .testTarget(
            name: "fueldHKPluginTests",
            dependencies: ["fueldHKPlugin"],
            path: "ios/Tests/fueldHKPluginTests")
    ]
)