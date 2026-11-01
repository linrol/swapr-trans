// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwaprTrans",
    platforms: [
        .macOS("14.2")
    ],
    products: [
        .library(
            name: "SwaprTransKit",
            targets: ["SwaprTransKit"]
        ),
        .executable(
            name: "SwaprTrans",
            targets: ["SwaprTrans"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/linrol/CreemLicenseKit.git", from: "1.0.1")
    ],
    targets: [
        .target(
            name: "SwaprTransKit",
            dependencies: [
                "CreemLicenseKit"
            ],
            path: "Sources/SwaprTransKit",
            linkerSettings: [
                .linkedFramework("CoreGraphics"),
                .linkedFramework("AppKit"),
                .linkedFramework("ApplicationServices"),
                .linkedFramework("Translation"),
                .linkedFramework("AVFoundation")
            ]
        ),
        .executableTarget(
            name: "SwaprTrans",
            dependencies: [
                "SwaprTransKit"
            ],
            path: "Sources/SwaprTrans"
        )
    ]
)
