import Foundation
import Combine

public final class Branch {
    weak var repository: Repository!
    private let prefix = "ref: refs/heads/"
    
    public var name: Future<String, Never> {
        .init { [weak self] promise in
            self?.repository.queue.async {
                guard let branch = self?.branch else { return }
                DispatchQueue.main.async {
                    promise(.success(branch))
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
    
    var commit: Id? {
        guard let data = try? Data(contentsOf: repository.url.heads.appendingPathComponent(branch)) else { return nil }
        return .init(.init(decoding: data, as: UTF8.self))
    }
    
    func commit(_ id: Id) {
        File.create(repository.url.heads)
        try! Data(id.hash.utf8).write(to: repository.url.heads.appendingPathComponent(branch), options: .atomic)
    }
    
    private var branch: String {
        String(decoding: Data(repository.url.HEAD), as: UTF8.self).dropFirst(prefix.count).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
