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
            url: "https://raw.githubusercontent.com/Voxai-Technology/CHClarityRecSDK/refs/heads/main/CHClarityRecSDK.xcframework.zip",
            checksum: "8f27c518a31131e097e14f1b58351d95a5a82d93c5538427e8e8f094d057e6ce"
        )
    ]
)
