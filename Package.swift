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
            url: "https://github.com/Voxai-Technology/CHClarityRecSDK/releases/download/0.0.20/CHClarityRecSDK.xcframework.zip",
            checksum: "cb02965878c7e8b49894c0af0d3459725ef4e35218e35aa0ab213966c81a3dfd"
        )
    ]
)


