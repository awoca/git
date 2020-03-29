import Foundation

final class File {
    class func directory(_ url: URL) -> Bool {
        var dir = ObjCBool(false)
        return FileManager.default.fileExists(atPath: url.path, isDirectory: &dir) && dir.boolValue
    }
    
    class func create(_ directory: URL) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false)
    }
    
    class func contents(_ url: URL) -> [String] {
        FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil)!.map { ($0 as! URL).resolvingSymlinksInPath().path }
    }
}
