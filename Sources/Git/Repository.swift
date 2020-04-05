import Foundation

public final class Repository {
    public var branch: Branch { _Branch.current(url) }
    public let status: Status
    public let url: URL
    let queue = DispatchQueue(label: "", qos: .utility)
    
    init(_ url: URL) {
        status = .init(url)
        self.url = url
    }
}
