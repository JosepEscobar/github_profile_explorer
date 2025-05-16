#if os(visionOS)
import Foundation
import RealityKit
import SwiftUI

public final class VisionOSUserProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public var username: String = ""
    @Published public var state: VisionOSViewState = .initial
    @Published public var isShowingSearchHistory: Bool = false
    @Published public var searchHistory: [String] = []
    @Published public var searchQuery: String = ""
    @Published public var urlToOpen: URL? = nil
    
    // MARK: - Use Cases
    private let fetchUserUseCase: FetchUserUseCaseProtocol
    private let fetchRepositoriesUseCase: FetchUserRepositoriesUseCaseProtocol
    private let manageSearchHistoryUseCase: ManageSearchHistoryUseCaseProtocol?
    private let filterRepositoriesUseCase: FilterRepositoriesUseCaseProtocol?
    private let openURLUseCase: OpenURLUseCaseProtocol?
    
    // MARK: - Computed Properties
    public var userUI: UserUIModel? {
        if case .loaded(let user, _) = state {
            return UserUIModel(from: user)
        }
        return nil
    }
    
    public var repositoriesUI: [RepositoryUIModel] {
        if case .loaded(_, let repos) = state {
            return repos.map { RepositoryUIModel(from: $0) }
        }
        return []
    }
    
    public var filteredRepositoriesUI: [RepositoryUIModel] {
        if searchQuery.isEmpty {
            return repositoriesUI
        }
        
        let filteredRepositories = filterRepositoriesUseCase?.filterBySearchText(repositories: repositories, searchText: searchQuery) ?? []
        return filteredRepositories.map { RepositoryUIModel(from: $0) }
    }
    
    private var user: User? {
        if case .loaded(let user, _) = state {
            return user
        }
        return nil
    }
    
    private var repositories: [Repository] {
        if case .loaded(_, let repos) = state {
            return repos
        }
        return []
    }
    
    // MARK: - Initializers
    public init(
        fetchUserUseCase: FetchUserUseCaseProtocol = FetchUserUseCase(repository: UserRepository(networkClient: NetworkClient())),
        fetchRepositoriesUseCase: FetchUserRepositoriesUseCaseProtocol = FetchUserRepositoriesUseCase(repository: UserRepository(networkClient: NetworkClient())),
        manageSearchHistoryUseCase: ManageSearchHistoryUseCaseProtocol? = nil,
        filterRepositoriesUseCase: FilterRepositoriesUseCaseProtocol? = nil,
        openURLUseCase: OpenURLUseCaseProtocol? = nil
    ) {
        self.fetchUserUseCase = fetchUserUseCase
        self.fetchRepositoriesUseCase = fetchRepositoriesUseCase
        self.manageSearchHistoryUseCase = manageSearchHistoryUseCase
        self.filterRepositoriesUseCase = filterRepositoriesUseCase
        self.openURLUseCase = openURLUseCase
        
        loadSearchHistory()
    }
    
    // MARK: - Public Methods
    
    public func fetchUserProfile() {
        guard !username.isEmpty else {
            state = .error(.unexpectedError("Username cannot be empty"))
            return
        }
        
        state = .loading
        
        Task { @MainActor in
            do {
                let user = try await fetchUserUseCase.execute(username: username)
                let repositories = try await fetchRepositoriesUseCase.execute(username: username)
                
                state = .loaded(user, repositories)
                manageSearchHistoryUseCase?.addToSearchHistory(username: username, platform: .visionOS)
                loadSearchHistory()
            } catch {
                if let appError = error as? AppError {
                    state = .error(appError)
                } else {
                    state = .error(.unexpectedError(error.localizedDescription))
                }
            }
        }
    }
    
    private func loadSearchHistory() {
        searchHistory = manageSearchHistoryUseCase?.loadSearchHistory(for: .visionOS) ?? []
    }
    
    public func clearSearchHistory() {
        manageSearchHistoryUseCase?.clearSearchHistory(for: .visionOS)
        searchHistory = []
    }
    
    public func removeSearchHistoryItem(at index: Int) {
        guard index < searchHistory.count else { return }
        
        let item = searchHistory[index]
        manageSearchHistoryUseCase?.removeFromHistory(username: item, platform: .visionOS)
        loadSearchHistory()
    }
    
    public func setSearchQuery(_ query: String) {
        searchQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public func openUserInGitHub() {
        guard let user = user else { return }
        urlToOpen = openURLUseCase?.createGitHubProfileURL(for: user.login)
    }
    
    public func openRepositoryInBrowser(_ repository: RepositoryUIModel) {
        urlToOpen = repository.htmlURL
    }
    
    public func getRepository(by id: Int) -> Repository? {
        return repositories.first { repository in
            repository.id == id
        }
    }
}

// MARK: - Estados de la vista para visionOS
public enum VisionOSViewState: Equatable {
    case initial
    case loading
    case loaded(User, [Repository])
    case error(AppError)
    
    public static func == (lhs: VisionOSViewState, rhs: VisionOSViewState) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial):
            return true
        case (.loading, .loading):
            return true
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.loaded(let lhsUser, let lhsRepos), .loaded(let rhsUser, let rhsRepos)):
            return lhsUser.id == rhsUser.id &&
                   lhsRepos.count == rhsRepos.count
        default:
            return false
        }
    }
}
#endif 
