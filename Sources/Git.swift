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
                self?.create(at: url)
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
    
    private func open(at: URL) throws -> Repository {
        guard File.directory(at.refs), File.directory(at.objects) else { throw Fail.Repository.none }
        return .init(at)
    }
    
    private func create(at: URL) {
        File.create(at.git)
        File.create(at.refs)
        File.create(at.objects)
        _Branch.checkoutMaster(at)
    }
}