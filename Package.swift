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
            url: "https://github.com/Voxai-Technology/CHClarityRecSDK/releases/download/0.0.23/CHClarityRecSDK.xcframework.zip",
            checksum: "0b2bd69dd5d422a3bab2d66b0f0be613c991c0ec7252cbbb356c851f4b96379b"
        )
    ]
)


