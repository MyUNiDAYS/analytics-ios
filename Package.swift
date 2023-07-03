// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "SegmentFirebase",
    platforms: [.iOS(.v11)],
    products: [.library(name: "SegmentFirebase", targets: ["SegmentFirebase"])],
    dependencies: [
        .package(name: "Segment", url: "https://github.com/segmentio/analytics-ios.git", .exact("4.1.4")),
        .package(name: "Firebase", url: "https://github.com/firebase/firebase-ios-sdk.git", .exact("10.2.0")),
    ],
    targets: [
        .target(
            name: "SegmentFirebase",
            dependencies: [
              "Segment",
              .product(name: "FirebaseAnalytics", package: "Firebase")
            ],
            path: "Segment-Firebase/Classes",
            publicHeadersPath: ""
        )
    ]
)
