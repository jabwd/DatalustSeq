import Vapor
import AsyncHTTPClient
import Serilog

var env = try Environment.detect()
let provider = SeqProvider()
let loggerMetadata: Logger.Metadata = [
  "Application": "Serilog test client"
]
LoggingSystem.bootstrap { label in
  provider.createNew(label: label, metadata: loggerMetadata)
}

let app = Application(env)
defer { app.shutdown() }

let seqIngestURL = URL(string: Environment.get("SEQ_API_URL")!)!
let seqCfg = SeqConfiguration(key: Environment.get("SEQ_API_KEY")!, ingestURL: seqIngestURL)
provider.eventLoopGroup = app.eventLoopGroup
provider.configuration = seqCfg
provider.startLogging()

app.routes.get("") { request -> HTTPStatus in
  app.logger.info("Received an request on /")
  app.logger.error("Error log message")
  app.logger.critical("Critical error")
  app.logger.warning("Warning error message")
  return .ok
}

app.logger.info("Launching logging test client")
try app.run()

