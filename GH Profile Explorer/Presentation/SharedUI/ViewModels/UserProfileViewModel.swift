import Foundation

public protocol UserProfileViewModelProtocol: ObservableObject {
    var state: ViewState { get }
    var username: String { get set }
    func fetchUserProfile()
}

open class UserProfileViewModel: UserProfileViewModelProtocol {
    @Published public var state: ViewState = .idle
    @Published public var username: String = ""
    
    let fetchUserUseCase: FetchUserUseCaseProtocol
    let fetchRepositoriesUseCase: FetchUserRepositoriesUseCaseProtocol
    
    public init(
        fetchUserUseCase: FetchUserUseCaseProtocol,
        fetchRepositoriesUseCase: FetchUserRepositoriesUseCaseProtocol
    ) {
        self.fetchUserUseCase = fetchUserUseCase
        self.fetchRepositoriesUseCase = fetchRepositoriesUseCase
    }
    
    open func fetchUserProfile() {
        guard !username.isEmpty else {
            state = .error(.unexpectedError("Username cannot be empty"))
            return
        }
        
        Task { @MainActor in
            self.state = .loading
            
            do {
                async let user = fetchUserUseCase.execute(username: username)
                async let repositories = fetchRepositoriesUseCase.execute(username: username)
                
                let (fetchedUser, fetchedRepositories) = try await (user, repositories)
                self.state = .loaded(fetchedUser, fetchedRepositories)
            } catch {
                if let appError = error as? AppError {
                    self.state = .error(appError)
                } else {
                    self.state = .error(.unexpectedError(error.localizedDescription))
                }
            }
        }
    }
} 