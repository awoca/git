import Foundation

public final class Repository {
    public var branch: Branch { _Branch.current(url) }
    public let status = Status()
    public let url: URL
    
    init(_ url: URL) {
        self.url = url
        status.repository = self
    }
}
