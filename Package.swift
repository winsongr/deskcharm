// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Deskcharm",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(name: "Deskcharm", path: "Sources/Deskcharm")
    ]
)
