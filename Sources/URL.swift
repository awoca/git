import Foundation

extension URL {
    var git: URL { appendingPathComponent(".git") }
    var ignore: URL { appendingPathComponent(".gitignore") }
    var refs: URL { git.appendingPathComponent("/refs") }
    var objects: URL { git.appendingPathComponent("/objects") }
    var HEAD: URL { git.appendingPathComponent("/HEAD") }
    var index: URL { git.appendingPathComponent("/index") }
    var exists: Bool { File.exists(self) }
    var heads: URL { refs.appendingPathComponent("heads") }
    
    func object(_ id: Id) -> URL {
        objects.appendingPathComponent(id.head).appendingPathComponent(id.tail)
    }
}
