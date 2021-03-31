//
//  Seq.swift
//  
//
//  Created by Antwan van Houdt on 18/02/2021.
//

import Foundation
import Dispatch
import Logging

public struct Seq: LogHandler {
    static let fileHandleQueue: DispatchQueue = DispatchQueue(label: "DatalustSeqLogHandler.FileHandle")

    private let label: String

    public static var client: SeqClient?
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
        guard let cfg = Self.configuration else {
            fatalError("SEQ Configuration required before logging can be enabled")
        }
        guard let client = Self.client else {
            fatalError("SEQ requires a HTTPClient before it can log messages")
        }
        client.log(msg, configuration: cfg)
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

    // MARK: -

    private var _logLevel: Logger.Level = .trace
    public var logLevel: Logger.Level {
        get {
            _logLevel
        }
        set {
            _logLevel = newValue
        }
    }
}
