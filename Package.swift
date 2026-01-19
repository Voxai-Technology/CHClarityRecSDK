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
            checksum: "fca74dca3419eb485b2ee72d2688c2064ebf858ca5a8b388bd912b8908a5eae6"
        )
    ]
)
