import Foundation

public protocol FetchUserUseCaseProtocol {
    func execute(username: String) async throws -> User
}

public final class FetchUserUseCase: FetchUserUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    public init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(username: String) async throws -> User {
        // Input validation
        guard !username.isEmpty else {
            throw AppError.unexpectedError("Username cannot be empty")
        }
        
        guard !username.contains(" ") else {
            throw AppError.unexpectedError("Username cannot contain spaces")
        }
        
        return try await repository.fetchUser(username: username)
    }
} 