// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FlubberCore",
    platforms: [.iOS(.v17), .macOS(.v13)],
    products: [.library(name: "FlubberCore", targets: ["FlubberCore"])],
    targets: [
        .target(name: "FlubberCore", path: "Shared", resources: [.process("Resources")]),
        .testTarget(name: "FlubberCoreTests", dependencies: ["FlubberCore"], path: "Tests/FlubberCoreTests")
    ]
)
