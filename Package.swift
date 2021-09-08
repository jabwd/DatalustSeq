// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "datalustseq",
  platforms: [
    .macOS(.v10_15)
  ],
  products: [
    .library(name: "DatalustSeq", targets: ["DatalustSeq"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.2.0"),
  ],
  targets: [
    .target(
      name: "DatalustSeq",
      dependencies: [
        .product(name: "Logging", package: "swift-log"),
        .product(name: "AsyncHTTPClient", package: "async-http-client"),
      ]),
    .testTarget(
      name: "DatalustSeqTests",
      dependencies: ["DatalustSeq"]),
  ]
)
