import Foundation
import Combine

public final class Repository {
    public var credentials = Credentials()
    public let url: URL
    public let status = Status()
    let queue = DispatchQueue(label: "", qos: .utility)
    let index = Index()
    private let head = Head()
    
    init(_ url: URL) {
        self.url = url
        status.repository = self
        head.repository = self
        index.repository = self
    }
    
    public var branch: Future<String, Never> {
        .init { [weak self] promise in
            self?.queue.async {
                guard let branch = self?.head.branch else { return }
                DispatchQueue.main.async {
                    promise(.success(branch))
                }
            }
        }
    }
    
    public var log: Future<Commit?, Never> {
        .init { [weak self] promise in
            self?.queue.async {
                DispatchQueue.main.async {
                    promise(.success(nil))
                }
            }
        }
    }
    
    public func branch(_ name: String) {
        queue.async { [weak self] in
            self?.head.branch(name)
        }
    }
    
    public func commit(_ paths: [String], message: String) {
        
    }
}
