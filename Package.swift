// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DatalustSeq",
    dependencies: [
		.package(url: "https://github.com/apple/swift-log.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "DatalustSeq",
            dependencies: [
				.product(name: "Logging", package: "swift-log"),
			]),
        .testTarget(
            name: "DatalustSeqTests",
            dependencies: ["DatalustSeq"]),
    ]
)
