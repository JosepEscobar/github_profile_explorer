import Foundation

public protocol FetchUserRepositoriesUseCaseProtocol {
    func execute(username: String) async throws -> [Repository]
}

public final class FetchUserRepositoriesUseCase: FetchUserRepositoriesUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    public init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(username: String) async throws -> [Repository] {
        // Input validation
        guard !username.isEmpty else {
            throw AppError.unexpectedError("Username cannot be empty")
        }
        
        guard !username.contains(" ") else {
            throw AppError.unexpectedError("Username cannot contain spaces")
        }
        
        return try await repository.fetchUserRepositories(username: username)
    }
} 