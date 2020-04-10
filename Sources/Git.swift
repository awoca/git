import Foundation
import Combine

public final class Git {
    public init() { }
    
    public func open(_ url: URL) -> Future<Repository?, Never> {
        .init { promise in
            let repository = Repository(url)
            repository.queue.async {
                guard File.directory(url.refs) && File.directory(url.objects) else {
                    DispatchQueue.main.async {
                        promise(.success(nil))
                    }
                    return
                }
                DispatchQueue.main.async {
                    promise(.success(repository))
                }
            }
        }
    }
    
    public func create(_ url: URL) -> Future<Repository, Never> {
        .init { promise in
            let repository = Repository(url)
            repository.queue.async {
                File.create(url.git)
                File.create(url.refs)
                File.create(url.objects)
                repository.branch("master")
                DispatchQueue.main.async {
                    promise(.success(repository))
                }
            }
        }
    }
}
