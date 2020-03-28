import Foundation
import Combine

public final class Git {
    private let queue = DispatchQueue(label: "", qos: .utility)
    
    public init() { }
    
    public func open(_ url: URL) -> Future<Repository, Error> {
        .init { [weak self] promise in
            self?.queue.async {
                do {
                    guard let repository = try self?.open(at: url) else { return }
                    DispatchQueue.main.async {
                        promise(.success(repository))
                    }
                } catch {
                    DispatchQueue.main.async {
                        promise(.failure(error))
                    }
                }
            }
        }
    }
    
    public func create(_ url: URL) -> Future<Repository, Error> {
        .init { [weak self] promise in
            self?.queue.async {
                do {
                    try self?.create(at: url)
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
    
    private func open(at: URL) throws -> Repository {
        throw Fail.Repository.noRepository
    }
    
    private func create(at: URL) throws {
        let root = at.appendingPathComponent(".git")
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false)
        
    }
}
