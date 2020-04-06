import Foundation

extension URL {
    var git: URL { appendingPathComponent(".git") }
    var ignore: URL { appendingPathComponent(".gitignore") }
    var refs: URL { git.appendingPathComponent("/refs") }
    var objects: URL { git.appendingPathComponent("/objects") }
    var HEAD: URL { git.appendingPathComponent("/HEAD") }
    var index: URL { git.appendingPathComponent("/index") }
    var exists: Bool { File.exists(self) }
}
