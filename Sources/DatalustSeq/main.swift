import Logging
import Foundation

internal final class SeqHTTPClient {
	let urlSession: URLSession
	let apiURL: URL
	let apiKey: String

	init(apiURL: URL, apiKey: String) {
		let configuration = URLSessionConfiguration()
		urlSession = URLSession(
			configuration: configuration,
			delegate: nil,
			delegateQueue: nil
		)
		self.apiKey = apiKey
		self.apiURL = apiURL.appendingPathComponent("api/events/raw?clef")
	}
	
	func postMessages() {
		var request = URLRequest(url: apiURL)
		request.addValue(apiKey, forHTTPHeaderField: "X-Seq-ApiKey")
		request.addValue("application/vnd.serilog.clef", forHTTPHeaderField: "Content-Type")
		let task = urlSession.dataTask(with: request) { (data, response, error) in
			
		}
		task.resume()
	}
}

public struct Seq: LogHandler {
	static var seqAPIURL: URL = URL(string: "https://localhost:5341")!
	static var apiKey: String = "8iKTq5R3KNmN4D27h2cY"
	
	func log(
		level: Logger.Level,
		message: Logger.Message,
		metadata: Logger.Metadata?,
		file: String,
		function: String,
		line: UInt8
	) {
		
	}

	public subscript(metadataKey _: String) -> Logger.Metadata.Value? {
		get {
			// do nothing
			return nil
		}
		set(newValue) {
			// do nothing
		}
	}

	var _metadata: Logger.Metadata? = nil
	public var metadata: Logger.Metadata {
		get {
			return _metadata!
		}
		set {
			_metadata = newValue
		}
	}

	private var _logLevel: Logger.Level = .critical
	public var logLevel: Logger.Level {
		get {
			_logLevel
		}
		set {
			_logLevel = newValue
		}
	}
}
