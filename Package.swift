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
            checksum: "c31e637243928bb213cd46e95d2d9245d05f6def7af238a407d1327f44bcffb4"
        )
    ]
)
