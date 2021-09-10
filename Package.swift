// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "serilog",
  platforms: [
    .macOS(.v10_15)
  ],
  products: [
    .library(name: "Serilog", targets: ["Serilog"]),
    .executable(name: "Testclient", targets: ["Testclient"])
  ],
  dependencies: [
    .package(name: "async-http-client", url: "https://github.com/swift-server/async-http-client.git", from: "1.2.0"),
    .package(name: "swift-log", url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    .package(name: "vapor", url: "https://github.com/vapor/vapor", from: "4.0.0"),
  ],
  targets: [
    .target(
      name: "Serilog",
      dependencies: [
        .product(name: "Logging", package: "swift-log"),
        .product(name: "AsyncHTTPClient", package: "async-http-client"),
      ]),
    .target(
      name: "Testclient",
      dependencies: [
        .product(name: "Vapor", package: "vapor"),
        "Serilog"
    ]),
    .testTarget(
      name: "DatalustSeqTests",
      dependencies: ["Serilog"]),
  ]
)
