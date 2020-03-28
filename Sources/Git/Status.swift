import Foundation
import Combine

public final class Status: Publisher {
    public typealias Output = StatusReport
    public typealias Failure = Never
    
    var repository: Repository!
    fileprivate var subs = [Sub]()
    
    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        subs.append(.init(.init(subscriber)))
    }
}

public protocol StatusReport { }

public struct CleanStatus: StatusReport { }

public struct ChangedStatus: StatusReport {
    public let items: Set<Item>
    
    public enum Status {
        case
        untracked,
        added,
        modified,
        deleted
    }
    
    public struct Item: Hashable {
        let status: Status
        let path: String
        
        public func hash(into: inout Hasher) {
            into.combine(path)
        }
        
        public static func != (lhs: Self, rhs: Self) -> Bool {
            lhs.path == rhs.path
        }
    }
}

private final class Sub: Subscription {
    weak var status: Status!
    private let subscriber: AnySubscriber<StatusReport, Never>
    
    init(_ subscriber: AnySubscriber<StatusReport, Never>) {
        self.subscriber = subscriber
    }
    
    func request(_ demand: Subscribers.Demand) { }
    func cancel() {
        status.subs.remove(at: status.subs.firstIndex { $0 === self }!)
    }
}
