// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MacPad",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "MacPad", targets: ["MacPad"])
    ],
    targets: [
        .executableTarget(
            name: "MacPad",
            path: "Sources/MacPad"
        ),
        .testTarget(
            name: "MacPadTests",
            dependencies: ["MacPad"],
            path: "Tests/MacPadTests"
        )
    ]
)
