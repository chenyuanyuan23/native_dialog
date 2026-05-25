// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "native_dialog",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "native-dialog", targets: ["native_dialog"])
    ],
    dependencies: [
        .package(url: "https://github.com/jdg/MBProgressHUD.git", from: "1.2.0")
    ],
    targets: [
        .target(
            name: "native_dialog",
            dependencies: [
                .product(name: "MBProgressHUD", package: "MBProgressHUD")
            ],
            path: "Sources/native_dialog",
            publicHeadersPath: "include"
        )
    ]
)
