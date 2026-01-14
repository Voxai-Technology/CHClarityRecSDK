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
            checksum: "ad43448023500ebee2779dc2869723c84010458add6078ca7d028267d461d0d7"
        )
    ]
)
