# Serilog

A simple logging implementation for Serilog users.

## Installation

Add the following line to your dependencies in your `Package.swift`

```swift
.package(name: "serilog", url: "https://github.com/jabwd/serilog", from: "0.2.0"),
```

## Example usage with Vapor:

```swift
var env = try Environment.detect()
let provider = SeqProvider()
LoggingSystem.bootstrap(provider.createNew)

let app = Application(env)
defer { app.shutdown() }

let seqIngestURL = URL(string: Environment.get("SEQ_API_URL")!)!
let seqCfg = SeqConfiguration(key: Environment.get("SEQ_API_KEY")!, ingestURL: seqIngestURL)
provider.eventLoopGroup = app.eventLoopGroup
provider.configuration = seqCfg
provider.startLogging()
```

## Adding default metadata to every log entry

```swift
let loggerMetadata: Logger.Metadata = [
  "Application": "Serilog test client"
]
LoggingSystem.bootstrap { label in
  provider.createNew(label: label, metadata: loggerMetadata)
}
```
