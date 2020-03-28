import Foundation

public final class Repository {
    public var branch: Branch { _Branch.current(url) }
    public let url: URL
    
    init(_ url: URL) {
        self.url = url
    }
}
