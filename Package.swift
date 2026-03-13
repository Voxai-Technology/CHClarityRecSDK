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
            url: "https://github.com/Voxai-Technology/CHClarityRecSDK/releases/download/0.0.24/CHClarityRecSDK.xcframework.zip",
            checksum: "43aa40205f19c7f2810a63584e146480df60ad3320077499fa2773755d1636cb"
        )
    ]
)


