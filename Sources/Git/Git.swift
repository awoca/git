import Foundation
import Combine

public final class Git {
    public init() { }
    
    public func open(_ url: URL) -> Future<Repository, Fail.Repository> {
        .init {
            $0(.failure(.noRepository))
        }
    }
}
