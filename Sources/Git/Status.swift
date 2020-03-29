import Foundation
import Combine

public final class Status: Publisher {
    public typealias Output = Report
    public typealias Failure = Never
    var repository: Repository!
    private var sub = Sub()
    
    public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Report == S.Input {
        sub.subscriber = .init(.init(subscriber))
    }
}

private final class Sub: Subscription {
    var subscriber: AnySubscriber<Report, Never>?
    
    func request(_ demand: Subscribers.Demand) { }
    
    func cancel() {
        subscriber = nil
    }
}
