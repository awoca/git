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
                DispatchQueue.main.async {
                    promise(.success(nil))
                }
            }
        }
    }
    
    public func commit(_ paths: Set<String>, message: String) {
        repository.queue.async { [weak self] in
            guard let self = self else { return }
            let author = Git.credentials.name +  " <" + Git.credentials.email +  "> \(Int(Date().timeIntervalSince1970)) " + self.timezone.string(from: .init())
            var serial = "tree " + self.repository.index.save(paths).hash
//            serial += "\nauthor " + author
//            serial += "\ncommitter " + author
//            serial += "\n\n" + message
            let pack = Hash.commit(serial)
            pack.save(self.repository.url)
            self.repository.branch.commit(pack.id)
        }
    }
}
