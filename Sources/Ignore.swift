import Foundation

final class Ignore {
    private(set) var cleared = Set<String>()
    private let commands: [Command]
    
    init(_ url: URL) {
        var folders = Folders()
        var relatives = Relatives()
        var names = Names()
        var leadingStar = LeadingStar()
        var trailingStar = TrailingStar()
        
        try? String(decoding: Data(contentsOf: url.ignore), as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n").forEach {
            if $0.hasPrefix("**/") {
                names.rules.insert(.init($0.dropFirst(3)))
            } else if $0.hasSuffix("/**") {
                relatives.rules.insert($0.hasPrefix("/") ? .init($0.dropFirst().dropLast(3)) : .init($0.dropLast(3)))
            } else if $0.hasPrefix("*") {
                leadingStar.rules.insert(.init($0.dropFirst()))
            } else if $0.hasSuffix("*") {
                trailingStar.rules.insert(.init($0.dropLast()))
            } else if $0.hasSuffix("/") {
                folders.rules.insert(($0.hasPrefix("/") ? "" : "/") + $0)
            } else {
                if $0.contains("/") {
                    relatives.rules.insert($0.hasPrefix("/") ? .init($0.dropFirst()) : $0)
                } else {
                    names.rules.insert($0)
                }
            }
        }
        commands = [folders, relatives, names, leadingStar, trailingStar]
    }
    
    func add(_ string: String) {
        for command in commands {
            guard command.validate(string) else { return }
            continue
        }
        cleared.insert(string)
    }
}

private protocol Command {
    var rules: Set<String> { get set }
    
    func validate(_ string: String) -> Bool
}

private struct Folders: Command {
    var rules = Set(["/.git/"])
    
    func validate(_ string: String) -> Bool {
        let compare = "/" + string
        for rule in rules {
            guard compare.contains(rule) else { continue }
            return false
        }
        return true
    }
}

private struct Relatives: Command {
    var rules = Set<String>()
    
    func validate(_ string: String) -> Bool {
        for rule in rules {
            var matches = false
            for zipped in zip(rule.components(separatedBy: "/"), string.components(separatedBy: "/")) {
                guard zipped.0 == zipped.1 else { break }
                matches = true
            }
            if matches {
                return false
            }
        }
        return true
    }
}

private struct Names: Command {
    var rules = Set<String>()
    
    func validate(_ string: String) -> Bool {
        for component in string.components(separatedBy: "/") {
            guard rules.contains(component) else { continue }
            return false
        }
        return true
    }
}

private struct LeadingStar: Command {
    var rules = Set<String>()
    
    func validate(_ string: String) -> Bool {
        for component in string.components(separatedBy: "/") {
            for rule in rules {
                guard component.hasSuffix(rule) else { continue }
                return false
            }
        }
        return true
    }
}

private struct TrailingStar: Command {
    var rules = Set<String>()
    
    func validate(_ string: String) -> Bool {
        for component in string.components(separatedBy: "/") {
            for rule in rules {
                guard component.hasPrefix(rule) else { continue }
                return false
            }
        }
        return true
    }
}
