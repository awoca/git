import Foundation

final class File {
    private static var manager = FileManager.default
    
    class func directory(_ url: URL) -> Bool {
        var dir = ObjCBool(false)
        return manager.fileExists(atPath: url.path, isDirectory: &dir) && dir.boolValue
    }
    
    class func create(_ directory: URL) throws {
        try manager.createDirectory(at: directory, withIntermediateDirectories: false)
    }
    
    class func contents(_ url: URL) -> Set<String> {
        manager.enumerator(at: url, includingPropertiesForKeys: [], options: .producesRelativePathURLs)!.reduce(into: Ignore(url)) {
            guard !($1 as! URL).hasDirectoryPath else { return }
            $0.add(($1 as! URL).relativePath)
        }.cleared
    }
}
