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
import NIO

extension DispatchSourceTimer {
  func schedule(delay: TimeInterval?, repeating: TimeInterval?) {
    schedule(deadline: delay.map { .now() + $0 } ?? .now(), repeating: repeating.map { .seconds(Int($0)) } ?? .never, leeway: repeating.map { .seconds(Int($0 / 2)) } ?? .nanoseconds(0))
  }
}

public class SeqProvider {
  var httpClient: HTTPClient?
  public var configuration: SeqConfiguration?
  public var eventLoopGroup: EventLoopGroup?
  var eventLoop: EventLoop!

  private var messages: [Message] = []

  public init() {
  }

  public func startLogging() {
    guard let eventLoopGroup = eventLoopGroup else {
      return
    }
    self.httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
    let eventLoop = eventLoopGroup.next()
    self.eventLoop = eventLoop

    eventLoop.scheduleRepeatedAsyncTask(initialDelay: .seconds(1), delay: .seconds(2), notifying: nil) { [weak self] repeatedTask in
      guard let self = self else {
        let promise = eventLoop.makePromise(of: Void.self)
        repeatedTask.cancel(promise: promise)
        return promise.futureResult
      }
      self.log()
      self.messages = []
      return self.eventLoop.makeSucceededFuture(())
    }
  }

  public func createNew(label: String) -> LogHandler {
    return Seq(label: label, provider: self)
  }

  // MARK: -

  func add(message: Message) {
    messages.append(message)
  }

  private func log() {
    guard
      messages.count > 0,
      let httpClient = httpClient,
      let configuration = configuration
    else {
      return
    }
    var buff = ByteBuffer()
    for message in messages {
      buff.writeBytes(message.compactLogEventFormat)
    }
    let body = HTTPClient.Body.byteBuffer(buff)
    let headers = HTTPHeaders([
      ("X-Seq-ApiKey", configuration.key),
      ("Content-Type", "application/vnd.serilog.clef")
    ])
    let request = try! HTTPClient.Request(
      url: configuration.ingestURL,
      method: .POST,
      headers: headers,
      body: body
    )
    _ = httpClient.execute(request: request)
  }
}

public struct Seq: LogHandler {
  public var logLevel = Logger.Level.info

  private let label: String
  private let provider: SeqProvider

  public init(label: String, provider: SeqProvider) {
    self.label = label
    self.provider = provider
  }

  public func log(level: Logger.Level,
                  message: Logger.Message,
                  metadata: Logger.Metadata?,
                  source: String,
                  file: String,
                  function: String,
                  line: UInt) {
    var finalMetadata: Logger.Metadata = _metadata
    if let metadata = metadata {
      finalMetadata.merge(metadata) { (lh, rh) in
        return "\(lh), \(rh)"
      }
    }
    let msg = Message(level: level, message: message, label: label, file: file, function: function, line: line, metadata: finalMetadata)
    provider.eventLoop.execute {
      provider.add(message: msg)
    }
  }

  // MARK: -

  public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
    get {
      return _metadata[key]
    }
    set(newValue) {
      _metadata[key] = newValue
    }
  }

  var _metadata: Logger.Metadata = [:]
  public var metadata: Logger.Metadata {
    get {
      return _metadata
    }
    set {
      _metadata = newValue
    }
  }
}
