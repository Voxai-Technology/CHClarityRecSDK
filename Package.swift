// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CHClarityRecSDK",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "CHClarityRecSDK", targets: ["CHClarityRecSDK"])
    ],
    targets: [
        .binaryTarget(
            name: "CHClarityRecSDK",
            url: "https://github.com/Voxai-Technology/CHClarityRecSDK/releases/download/0.0.12/CHClarityRecSDK.xcframework.zip",
            checksum: "1bc85338623cb8b0a7d3ac9167f41ad2da9c745bd4fd75ad4fa64e807275d019"
        )
    ]
)
