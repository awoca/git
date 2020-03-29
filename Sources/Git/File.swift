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
        FileManager.default.enumerator(atPath: url.path)!.reduce(into: ([], ignore(url))) {
            for i in $0.1 {
                guard ($1 as! String).contains(i) else { continue }
                return
            }
            $0.0.insert($1 as! String)
        }.0
    }
    
    private class func ignore(_ url: URL) -> Set<String> {
        [".git"]
    }
}
