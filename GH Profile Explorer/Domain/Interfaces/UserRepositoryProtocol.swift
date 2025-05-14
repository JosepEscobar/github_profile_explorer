import Foundation

public protocol UserRepositoryProtocol {
    func fetchUser(username: String) async throws -> User
    func fetchUserRepositories(username: String) async throws -> [Repository]
    func searchUsers(query: String) async throws -> [User]
} 