import Logging
import Foundation
import AsyncHTTPClient

@propertyWrapper
public class Atomic<T> {
    private let queue = DispatchQueue(label: "DatalustSeqLogHandler.AtomicProperty", attributes: .concurrent)
    private var value: T
    public var wrappedValue: T {
        get { queue.sync { value } }
        set { queue.async(flags: .barrier) { self.value = newValue } }
    }
    public init(wrappedValue: T) {
        value = wrappedValue
    }
}

//static let timer: DispatchSourceTimer = {
//    let timer = DispatchSource.makeTimerSource()
//    timer.setEventHandler(handler: uploadOnSchedule)
//    timer.activate()
//    return timer
//}()

//extension DispatchSourceTimer {
//    func schedule(delay: TimeInterval?, repeating: TimeInterval?) {
//        schedule(deadline: delay.map { .now() + $0 } ?? .now(), repeating: repeating.map { .seconds(Int($0)) } ?? .never, leeway: repeating.map { .seconds(Int($0 / 2)) } ?? .nanoseconds(0))
//    }
//}

let client = HTTPClient(eventLoopGroupProvider: .createNew)
defer {
    sleep(4)
    try? client.syncShutdown()
}

Seq.client = SeqClient(httpClient: client)
Seq.configuration = SeqConfiguration(key: "ffsbqBBtktK3fgZ9aOzG", ingestURL: URL(string: "https://ingest.seq.exploretriple.com")!)
LoggingSystem.bootstrap { MultiplexLogHandler([Seq(label: $0), StreamLogHandler.standardOutput(label: $0)]) }
let logger = Logger(label: "nl.triple-it.dev-seq-logger")

