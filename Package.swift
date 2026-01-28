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
            url: "https://github.com/Voxai-Technology/CHClarityRecSDK/releases/download/0.0.15/CHClarityRecSDK.xcframework.zip",
            checksum: "48f5b14a8c09de1081b6f2d373c20954a0cdb3a428c4e7f1ba29139be785f5ce"
        )
    ]
)


