import Foundation

final class File {
    class func directory(_ url: URL) -> Bool {
        var dir = ObjCBool(false)
        return FileManager.default.fileExists(atPath: url.path, isDirectory: &dir) && dir.boolValue
    }
    
    class func create(_ directory: URL) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false)
    }
    
    class func contents(_ url: URL) -> Set<String> {
        FileManager.default.enumerator(atPath: url.path)!.reduce(into: Ignore(url)) {
            $0.add($1 as! String)
        }.cleared
    }
}

private final class Ignore {
    private(set) var cleared = Set<String>()
    private let folders = ["/.git/"]
    
    init(_ url: URL) {
        
    }
    
    func add(_ string: String) {
        guard pass(folders: string) else { return }
        cleared.insert(string)
    }
    
    private func pass(folders string: String) -> Bool {
        let compare = "/" + string + "/"
        for folder in folders {
            guard compare.contains(folder) else { continue }
            return false
        }
        return true
    }
}
