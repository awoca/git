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
    
    private func send() {
        let contents = File.contents(repository.url)
        if contents.isEmpty {
            _ = sub?.receive(Clean())
        } else {
            _ = sub?.receive(Changes(items: .init(contents.map { .init(status: .untracked, path: $0) })))
        }
    }
}
