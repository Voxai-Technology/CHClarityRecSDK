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
            checksum: "b8139231ffc4c66dff4f779204328d9c8b4e05bcfc2483ac6cb0855c7bd20611"
        )
    ]
)
