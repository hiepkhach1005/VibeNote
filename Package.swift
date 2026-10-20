// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "VibeNote",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "VibeNote", targets: ["VibeNote"])
    ],
    targets: [
        .executableTarget(
            name: "VibeNote",
            path: "Sources/VibeNote"
        ),
        .testTarget(
            name: "VibeNoteTests",
            dependencies: ["VibeNote"],
            path: "Tests/VibeNoteTests"
        )
    ]
)
