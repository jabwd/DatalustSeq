//
//  Seq.swift
//  
//
//  Created by Antwan van Houdt on 18/02/2021.
//

import Foundation
import Dispatch
import Logging
import AsyncHTTPClient
import NIOHTTP1

//import Logging
//import Foundation
//import AsyncHTTPClient
//
//@propertyWrapper
//public class Atomic<T> {
//    private let queue = DispatchQueue(label: "DatalustSeqLogHandler.AtomicProperty", attributes: .concurrent)
//    private var value: T
//    public var wrappedValue: T {
//        get { queue.sync { value } }
//        set { queue.async(flags: .barrier) { self.value = newValue } }
//    }
//    public init(wrappedValue: T) {
//        value = wrappedValue
//    }
//}
//
////static let timer: DispatchSourceTimer = {
////    let timer = DispatchSource.makeTimerSource()
////    timer.setEventHandler(handler: uploadOnSchedule)
////    timer.activate()
////    return timer
////}()
//
////extension DispatchSourceTimer {
////    func schedule(delay: TimeInterval?, repeating: TimeInterval?) {
////        schedule(deadline: delay.map { .now() + $0 } ?? .now(), repeating: repeating.map { .seconds(Int($0)) } ?? .never, leeway: repeating.map { .seconds(Int($0 / 2)) } ?? .nanoseconds(0))
////    }
////}
//
//let client = HTTPClient(eventLoopGroupProvider: .createNew)
//defer {
//    sleep(4)
//    try? client.syncShutdown()
//}
//
//Seq.client = SeqClient(httpClient: client)
//Seq.configuration = SeqConfiguration(key: "ffsbqBBtktK3fgZ9aOzG", ingestURL: URL(string: "https://ingest.seq.exploretriple.com")!)
//LoggingSystem.bootstrap { MultiplexLogHandler([Seq(label: $0), StreamLogHandler.standardOutput(label: $0)]) }
//let logger = Logger(label: "nl.triple-it.dev-seq-logger")



public struct Seq: LogHandler {
    public var logLevel = Logger.Level.info {
        didSet {
            print("Did set new Value \(self.logLevel)")
        }
    }

    static let fileHandleQueue: DispatchQueue = DispatchQueue(label: "DatalustSeqLogHandler.FileHandle")

    private let label: String

    public static var httpClient: HTTPClient?
    public static var configuration: SeqConfiguration?

    public init(label: String) {
        self.label = label
    }

    public func log(level: Logger.Level,
                    message: Logger.Message,
                    metadata: Logger.Metadata?,
                    source: String,
                    file: String,
                    function: String,
                    line: UInt) {
        let msg = Message(level: level, message: message, file: file, function: function, line: line, metadata: metadata)
        // TODO: Buffer the messages here
        log(messages: [msg])
    }

    // MARK: -

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

    // MARK: - API

    private func log(messages: [Message]) {
        // For no we simply supress
        guard let configuration = Self.configuration else {
            print("[ NOTICE ] Suppressing \(messages) as no SEQ configuration is available yet")
            return
        }
        guard let client = Self.httpClient else {
            print("[ NOTICE ] Suppressing \(messages) as no HTTP client is available for SEQ")
            return
        }
        let newLine: [UInt8] = Array("\r\n".utf8)
        var finalBody: [UInt8] = [UInt8](repeating: 0, count: 0)

        // TODO: We can optimize this transformation stuff a lot here, optimize the data
        // reduce the amount of conversions between objects etc.etc.
        finalBody.reserveCapacity(512)
        for message in messages {
            guard let msgBody = message.clefMessage else {
                continue
            }
            finalBody.append(contentsOf: msgBody)
            finalBody.append(contentsOf: newLine)
        }
        let body = HTTPClient.Body.data(Data(finalBody))
        let headers = HTTPHeaders([
            ("X-Seq-ApiKey", configuration.key),
            ("Content-Type", "application/vnd.serilog.clef")
        ])
        let url = URL(string: "\(Self.configuration!.ingestURL.absoluteString)/api/events/raw?clef")!
        let request = try! HTTPClient.Request(
            url: url,
            method: .POST,
            headers: headers,
            body: body
        )
//        client.execute(request: request).whenComplete({ result in
//            switch result {
//            case .success(let resp):
//                print("HTTP Request succeeded: \(resp.status)")
//                break
//            case .failure(let error):
//                print("HTTP Request failed: \(error)")
//                break
//            }
//        })
        _ = client.execute(request: request)
    }
}
