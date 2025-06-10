// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Poster",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "Poster",
            targets: ["Poster"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", from: "1.16.0")
    ],
    targets: [
        .executableTarget(
            name: "Poster",
            dependencies: ["KeyboardShortcuts"],
            path: "Sources"
        )
    ]
)