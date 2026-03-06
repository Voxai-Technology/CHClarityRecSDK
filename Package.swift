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
            url: "https://github.com/Voxai-Technology/CHClarityRecSDK/releases/download/0.0.22/CHClarityRecSDK.xcframework.zip",
            checksum: "sha256:bf75b0dbd1cc13cc45869da0e54e9e83fbed3a226bf069a5a3b7c62d8367dfbb"
        )
    ]
)


