import Foundation

extension URL {
    var git: URL { appendingPathComponent(".git") }
    var refs: URL { git.appendingPathComponent("/refs") }
    var objects: URL { git.appendingPathComponent("/objects") }
    var HEAD: URL { git.appendingPathComponent("/HEAD") }
    var ignore: URL { git.appendingPathComponent(".gitignore") }
}
