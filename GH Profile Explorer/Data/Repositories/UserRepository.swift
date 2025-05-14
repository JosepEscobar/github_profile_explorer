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
        var allRepositories: [RepositoryResponse] = []
        var page = 1
        let perPage = 100
        
        while true {
            let endpoint = Endpoint.userRepositories(
                username: username,
                page: page,
                perPage: perPage
            )
            
            let repositories: [RepositoryResponse] = try await networkClient.fetch(endpoint: endpoint)
            
            allRepositories.append(contentsOf: repositories)
            
            if repositories.count < perPage {
                break
            }
            
            page += 1
        }
        
        return try RepositoryMapper.mapToDomain(responses: allRepositories)
    }
    
    public func searchUsers(query: String) async throws -> [User] {
        let endpoint = Endpoint.searchUsers(query: query)
        let response: UserSearchResponse = try await networkClient.fetch(endpoint: endpoint)
        return try UserMapper.mapSearchResponseToDomain(response: response)
    }
} 