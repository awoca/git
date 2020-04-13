import Foundation
import Combine

public final class Log {
    weak var repository: Repository!
    private let timezone = DateFormatter()
    
    init() {
        timezone.dateFormat = "xx"
    }
    
    public var history: Future<Commit?, Never> {
        .init { [weak self] promise in
            self?.repository.queue.async {
                guard let self = self else { return }
                let commit = self.repository.branch.commit.map { Commit(self.repository.url, id: $0) }
                DispatchQueue.main.async {
                    promise(.success(commit))
                }
            }
        }
    }
    
    public func commit(_ paths: Set<String>, message: String) {
        repository.queue.async { [weak self] in
            guard let self = self else { return }
            let date = Date()
            let author = Git.credentials.name + " <" + Git.credentials.email + "> \(Int(date.timeIntervalSince1970)) " + self.timezone.string(from: date)
            var commit = "tree " + self.repository.index.save(paths).hash
            self.repository.branch.commit.map { commit += "\nparent " + $0.hash }
            commit += "\nauthor " + author
            commit += "\ncommitter " + author
            commit += "\n\n" + message
            let pack = Hash.commit(commit)
            pack.save(self.repository.url)
            self.repository.branch.commit(pack.id)
        }
    }
}
