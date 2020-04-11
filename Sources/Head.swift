import Foundation

final class Head {
    weak var repository: Repository!
    private let prefix = "ref: refs/heads/"

    var branch: String {
        String(decoding: Data(repository.url.HEAD), as: UTF8.self).dropFirst(prefix.count).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func branch(_ name: String) {
        try! Data((prefix + name).utf8).write(to: repository.url.HEAD, options: .atomic)
    }
}
