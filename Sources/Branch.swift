import Foundation
import Combine

public final class Branch {
    weak var repository: Repository!
    private let prefix = "ref: refs/heads/"
    
    public var name: Future<String, Never> {
        .init { [weak self] promise in
            self?.repository.queue.async {
                guard let self = self else { return }
                let name = String(decoding: Data(self.repository.url.HEAD), as: UTF8.self).dropFirst(self.prefix.count).trimmingCharacters(in: .whitespacesAndNewlines)
                DispatchQueue.main.async {
                    promise(.success(name))
                }
            }
        }
    }
    
    public func change(_ to: String) {
        repository.queue.async { [weak self] in
            guard let self = self else { return }
            try! Data((self.prefix + to).utf8).write(to: self.repository.url.HEAD, options: .atomic)
        }
    }
}
