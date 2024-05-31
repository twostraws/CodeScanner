// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CodeScanner",
    platforms: [.iOS(.v13), .macOS(.v10_15), .tvOS(.v13), .visionOS(.v1), .watchOS(.v6)],
    products: [.library(name: "CodeScanner", targets: ["CodeScanner"])],
    dependencies: [],
    targets: [.target(name: "CodeScanner", dependencies: [])]
)
