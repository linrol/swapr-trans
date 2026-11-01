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
        .package(path: "../CreemLicenseKit")
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
