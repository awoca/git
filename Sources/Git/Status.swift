import Foundation
import Combine

public final class Status: Publisher, Subscription {
    public typealias Output = Report
    public typealias Failure = Never
    
    weak var repository: Repository!
    private var sub: AnySubscriber<Report, Never>?
    private var stream: FSEventStreamRef?
    
    var index: [Indexed] {
        []
    }
    
    deinit {
        stop()
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Report == S.Input {
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
        let contents = File.contents(repository.url)
        if contents.isEmpty {
            _ = sub?.receive(Clean())
        } else {
            _ = sub?.receive(Changes(items: .init(contents.map { .init(status: .untracked, path: $0) })))
        }
    }
    
    private func start() {
        guard stream == nil else { return }
        var context = FSEventStreamContext(version: 0, info: Unmanaged.passUnretained(self).toOpaque(), retain: nil, release: nil, copyDescription: nil)
        stream = FSEventStreamCreate(kCFAllocatorDefault, { _, context, _, _, _, _ in
            Unmanaged<Status>.fromOpaque(context!).takeUnretainedValue().send()
        }, &context, [repository.url.path] as CFArray, .init(kFSEventStreamEventIdSinceNow), 0.01, .init(kFSEventStreamCreateFlagNone))
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
