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
            url: "https://gitee.com/superwangdg/chclarity-rec-sdkfor-ios/raw/0.1.2/CHClarityRecSDK.xcframework.zip",
            checksum: "d7fb85403be84c17127a35f901544c0948fde90c579b38742662ea2163e8683d"
        )
    ]
)
