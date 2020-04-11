import Foundation
import Combine

public final class Log {
    weak var repository: Repository!
    
    public var history: Future<Commit?, Never> {
        .init { [weak self] promise in
            self?.repository.queue.async {
                DispatchQueue.main.async {
                    promise(.success(nil))
                }
            }
        }
    }
    
    public func commit(_ paths: [String], message: String) {
        repository.queue.async {
            
        }
    }
}
