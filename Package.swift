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
            checksum: "3fb6c51f657f950d49069710eaca0d72e8d25b2ef1b81d9e57b71bf7bbc9f381"
        )
    ]
)
