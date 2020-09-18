// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "RSBarcodes_Swift",
    platforms: [.iOS(.v9)],
    products: [
        .library(name: "RSBarcodes_Swift", targets: ["RSBarcodes_Swift"]),
    ],
    targets: [
        .target(
            name: "RSBarcodes_Swift",
            path: "Source"
        ),
    ]
)
