// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QRCodeKit",
    products: [
        .library(
            name: "QRCodeKit",
            targets: ["QRCodeKit"]),
    ],
    targets: [
        .target(
            name: "QRCodeKit"),
        .testTarget(
            name: "QRCodeKitTests",
            dependencies: ["QRCodeKit"]
        ),
    ]
)
