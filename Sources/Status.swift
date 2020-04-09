import Foundation
import Combine

public final class Status: Publisher, Subscription {
    public enum Mode {
        case
        untracked,
        added,
        modified,
        deleted
    }
    
    public struct Item: Hashable {
        public let mode: Mode
        public let path: String
        
        fileprivate static func untracked(_ path: String) -> Item {
            .init(mode: .untracked, path: path)
        }
        
        public func hash(into: inout Hasher) {
            into.combine(path)
        }
        
        public static func != (lhs: Self, rhs: Self) -> Bool {
            lhs.path == rhs.path
        }
    }
    
    public typealias Output = Set<Item>
    public typealias Failure = Never
    
    private var sub: AnySubscriber<Output, Failure>?
    private var stream: FSEventStreamRef?
    private let index: Index
    private let url: URL
    
    init(_ url: URL) {
        index = .init(url)
        self.url = url
    }
    
    deinit {
        stop()
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        sub = .init(subscriber)
        subscriber.receive(subscription: self)
        start()
    }
    
    public func request(_ demand: Subscribers.Demand) { }

    public func cancel() {
        stop()
        sub = nil
    }
    
    private func send() {
        _ = sub?.receive(.init(File.contents(url).map(Item.untracked)))
    }
    
    private func start() {
        guard stream == nil else { return }
        var context = FSEventStreamContext(version: 0, info: Unmanaged.passUnretained(self).toOpaque(), retain: nil, release: nil, copyDescription: nil)
        stream = FSEventStreamCreate(kCFAllocatorDefault, { _, context, _, _, _, _ in
            Unmanaged<Status>.fromOpaque(context!).takeUnretainedValue().send()
        }, &context, [url.path] as CFArray, .init(kFSEventStreamEventIdSinceNow), 0.01, .init(kFSEventStreamCreateFlagNone))
        FSEventStreamSetDispatchQueue(stream!, DispatchQueue.main)
        FSEventStreamStart(stream!)
        FSEventStreamFlushAsync(stream!)
    }
    
    private func stop() {
        guard let stream = self.stream else { return }
        FSEventStreamStop(stream)
        FSEventStreamInvalidate(stream)
        FSEventStreamRelease(stream)
    }
}
