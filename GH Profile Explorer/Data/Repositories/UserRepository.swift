import Foundation

public final class UserRepository: UserRepositoryProtocol {
    private let networkClient: NetworkClientProtocol
    
    public init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }
    
    public func fetchUser(username: String) async throws -> User {
        let endpoint = Endpoint.user(username: username)
        let response: UserResponse = try await networkClient.fetch(endpoint: endpoint)
        return try UserMapper.mapToDomain(response: response)
    }
    
    public func fetchUserRepositories(username: String) async throws -> [Repository] {
        let endpoint = Endpoint.userRepositories(username: username)
        let response: [RepositoryResponse] = try await networkClient.fetch(endpoint: endpoint)
        return try RepositoryMapper.mapToDomain(responses: response)
    }
    
    public func searchUsers(query: String) async throws -> [User] {
        let endpoint = Endpoint.searchUsers(query: query)
        let response: UserSearchResponse = try await networkClient.fetch(endpoint: endpoint)
        return try UserMapper.mapSearchResponseToDomain(response: response)
    }
} 