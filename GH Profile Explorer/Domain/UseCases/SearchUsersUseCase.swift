import Foundation

public protocol SearchUsersUseCaseProtocol {
    func execute(query: String) async throws -> [User]
}

public final class SearchUsersUseCase: SearchUsersUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    public init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(query: String) async throws -> [User] {
        // Input validation
        guard !query.isEmpty else {
            throw AppError.unexpectedError("Search query cannot be empty")
        }
        
        return try await repository.searchUsers(query: query)
    }
} 