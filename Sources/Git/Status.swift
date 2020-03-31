import Foundation
import Combine

public final class Status: Publisher, Subscription {
    public typealias Output = Report
    public typealias Failure = Never
    
    var repository: Repository!
    private var sub: AnySubscriber<Report, Never>?
    
    var index: [Indexed] {
        []
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Report == S.Input {
        sub = .init(subscriber)
        subscriber.receive(subscription: self)
        send()
    }
    
    public func request(_ demand: Subscribers.Demand) { }

    public func cancel() {
        sub = nil
    }
    
    var stream: FSEventStreamRef?
    
    func start() {
        var context = FSEventStreamContext(version: 0, info: Unmanaged.passUnretained(self).toOpaque(), retain: nil, release: nil, copyDescription: nil)
        stream = FSEventStreamCreate(kCFAllocatorDefault, eventCallback, &context, [repository.url.path] as CFArray, FSEventStreamEventId(kFSEventStreamEventIdSinceNow), 0, UInt32(kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagFileEvents))
        FSEventStreamSetDispatchQueue(stream!, repository.queue)
        FSEventStreamStart(stream!)
    }
    
    private func send() {
        let contents = File.contents(repository.url)
        if contents.isEmpty {
            _ = sub?.receive(Clean())
        } else {
            _ = sub?.receive(Changes(items: .init(contents.map { .init(status: .untracked, path: $0) })))
        }
    }
    
    let eventCallback: FSEventStreamCallback = {(
       stream: ConstFSEventStreamRef,
       contextInfo: UnsafeMutableRawPointer?,
       numEvents: Int,
       eventPaths: UnsafeMutableRawPointer,
       eventFlags: UnsafePointer<FSEventStreamEventFlags>,
       eventIds: UnsafePointer<FSEventStreamEventId>
       ) in
        Swift.print("---------------------------- \(numEvents)")
        Swift.print(Unmanaged<CFArray>.fromOpaque(eventPaths).takeUnretainedValue() as! [String])
        Swift.print("----------------------------")
//       let fileSystemWatcher = Unmanaged<FileWatcher>.fromOpaque(contextInfo!).takeUnretainedValue()
//       let paths = Unmanaged<CFArray>.fromOpaque(eventPaths).takeUnretainedValue() as! [String]
//       (0..<numEvents).indices.forEach { index in
//          fileSystemWatcher.callback?(FileWatcherEvent(eventIds[index], paths[index], eventFlags[index]))
//       }
    }
}
