import Foundation

public final class Repository {
    public let url: URL
    public let branch = Branch()
    public let status = Status()
    public let log = Log()
    let queue = DispatchQueue(label: "", qos: .utility)
    let index = Index()
    
    init(_ url: URL) {
        self.url = url
        branch.repository = self
        status.repository = self
        log.repository = self
        index.repository = self
    }
}
