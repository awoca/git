import Foundation
import Combine

public final class Status: Publisher, Subscription {
    public struct Output {
        var untracked = Set<String>()
        var added = Set<String>()
        var modified = Set<String>()
        var deleted = Set<String>()
    }
    
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
        var output = Output()
        let items = index.items
        File.contents(url).forEach { path in
            if items.contains(where: { $0.path == path }) {
                output.added.insert(path)
            } else {
                output.untracked.insert(path)
            }
        }
        DispatchQueue.main.async { [weak self] in
            _ = self?.sub?.receive(output)
        }
    }
    
    private func start() {
        guard stream == nil else { return }
        var context = FSEventStreamContext(version: 0, info: Unmanaged.passUnretained(self).toOpaque(), retain: nil, release: nil, copyDescription: nil)
        stream = FSEventStreamCreate(kCFAllocatorDefault, { _, context, _, _, _, _ in
            Unmanaged<Status>.fromOpaque(context!).takeUnretainedValue().send()
        }, &context, [url.path] as CFArray, .init(kFSEventStreamEventIdSinceNow), 0.01, .init(kFSEventStreamCreateFlagNone))
        FSEventStreamSetDispatchQueue(stream!, .init(label: "", qos: .utility))
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
