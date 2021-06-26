// swift-tools-version:5.4

import PackageDescription

let package = Package(
    name: "PortfolioSite",
    products: [
        .executable(
            name: "PortfolioSite",
            targets: ["PortfolioSite"]
        )
    ],
    dependencies: [
        .package(name: "Publish", url: "https://github.com/johnsundell/publish.git", .upToNextMinor(from: "0.8.0")),
        .package(name: "SplashPublishPlugin", url: "https://github.com/johnsundell/splashpublishplugin.git", from: "0.1.0"),
        .package(name: "DarkImagePublishPlugin", url: "https://github.com/insidegui/DarkImagePublishPlugin.git", from: "0.1.0"),
        .package(name: "TinySliderPublishPlugin", url: "https://github.com/CoolONEOfficial/TinySliderPlugin.git", from: "0.1.3"),
        .package(name: "FTPPublishDeploy", url: "https://github.com/CoolONEOfficial/FTPPublishDeploy.git", from: "0.1.0")
    ],
    targets: [
        .executableTarget(
            name: "PortfolioSite",
            dependencies: [
                "Publish",
                "SplashPublishPlugin",
                "DarkImagePublishPlugin",
                "TinySliderPublishPlugin",
                "FTPPublishDeploy"
            ]
        )
    ]
)
