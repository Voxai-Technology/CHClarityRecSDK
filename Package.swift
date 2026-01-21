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
            url: "https://github.com/Voxai-Technology/CHClarityRecSDK/releases/download/0.0.11/CHClarityRecSDK.xcframework.zip",
            checksum: "13cd8f3c495e9e3b05e9c1e6bdae8bf99819dae99cf86e3196094e6b343c6f5e"
        )
    ]
)
