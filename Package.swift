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
            url: "https://github.com/Voxai-Technology/CHClarityRecSDK/releases/download/0.0.19/CHClarityRecSDK.xcframework.zip",
            checksum: "2bc203a2e66919d9d1911b5b15a1c55ebce9172921f463a5e0b330bafdf8852b"
        )
    ]
)


