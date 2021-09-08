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


public struct Seq: LogHandler {
  static internal let queue = DispatchQueue(
    label: "datalustseq.loghandler.atomicPropertyWrapper",
    attributes: .concurrent
  )

  static let timer: DispatchSourceTimer = {
    let timer = DispatchSource.makeTimerSource()
    timer.setEventHandler {
      Self.log(messages: Self.messages)
    }
    timer.activate()
    return timer
  }()

  @Atomic
  public static var scheduled: Bool = false

  @Atomic
  public static var httpClient: HTTPClient?

  @Atomic
  public static var configuration: SeqConfiguration?

  @Atomic
  public var logLevel = Logger.Level.info

  @Atomic
  private static var messages: [Message] = []

  private let label: String

  public init(label: String) {
    self.label = label
    if Self.scheduled == false {
      Self.timer.schedule(delay: 1.0, repeating: 2)
      Self.scheduled = true
    }
  }

  public func log(level: Logger.Level,
                  message: Logger.Message,
                  metadata: Logger.Metadata?,
                  source: String,
                  file: String,
                  function: String,
                  line: UInt) {
    let msg = Message(level: level, message: message, file: file, function: function, line: line, metadata: metadata)
    Self.messages.append(msg)
  }

  // MARK: -

  public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
    get {
      // do nothing
      print("Get metadat: \(key)")
      return nil
    }
    set(newValue) {
      // do nothing
      print("Set metadat: key:\(String(describing: newValue))")
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

  private static func log(messages: [Message]) {
    // For now we simply supress log messages sent before we can do anything with them
    guard let configuration = Self.configuration else {
      print("[ NOTICE ] Suppressing \(messages) as no SEQ configuration is available yet")
      return
    }
    guard let client = Self.httpClient else {
      print("[ NOTICE ] Suppressing \(messages) as no HTTP client is available for SEQ")
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
    let url = URL(string: "\(configuration.ingestURL.absoluteString)/api/events/raw?clef")!
    let request = try! HTTPClient.Request(
      url: url,
      method: .POST,
      headers: headers,
      body: body
    )
    _ = client.execute(request: request)
  }
}
