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
    
    // MARK: - Computed Properties
    
    // UIModels comunes para la vista
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
        // Si no hay consulta de búsqueda, devolvemos todos los repositorios
        if searchQuery.isEmpty {
            return repositoriesUI
        }
        
        // Filtramos los repositorios por texto de búsqueda (términos múltiples)
        let searchTerms = searchQuery.lowercased().split(separator: " ")
        
        return repositoriesUI.filter { repo in
            let nameMatch = repo.name.lowercased().contains(searchQuery.lowercased())
            let descriptionMatch = repo.description?.lowercased().contains(searchQuery.lowercased()) ?? false
            
            // Búsqueda general
            if nameMatch || descriptionMatch {
                return true
            }
            
            // Búsqueda por términos múltiples
            for term in searchTerms {
                let termStr = String(term)
                if repo.name.lowercased().contains(termStr) ||
                   (repo.description?.lowercased().contains(termStr) ?? false) {
                    return true
                }
            }
            
            return false
        }
    }
    
    // MARK: - Use Cases
    private let fetchUserUseCase: FetchUserUseCaseProtocol
    private let fetchRepositoriesUseCase: FetchUserRepositoriesUseCaseProtocol
    private let manageSearchHistoryUseCase: ManageSearchHistoryUseCaseProtocol?
    private let filterRepositoriesUseCase: FilterRepositoriesUseCaseProtocol?
    private let openURLUseCase: OpenURLUseCaseProtocol?
    
    // MARK: - Referencias para la escena 3D
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
    
    // Constructor con inyección completa de dependencias
    public init(
        fetchUserUseCase: FetchUserUseCaseProtocol? = nil,
        fetchRepositoriesUseCase: FetchUserRepositoriesUseCaseProtocol? = nil,
        manageSearchHistoryUseCase: ManageSearchHistoryUseCaseProtocol? = nil,
        filterRepositoriesUseCase: FilterRepositoriesUseCaseProtocol? = nil,
        openURLUseCase: OpenURLUseCaseProtocol? = nil
    ) {
        // Si no se proporcionan, creamos implementaciones por defecto
        self.fetchUserUseCase = fetchUserUseCase ?? FetchUserUseCase(repository: UserRepository(networkClient: NetworkClient()))
        self.fetchRepositoriesUseCase = fetchRepositoriesUseCase ?? FetchUserRepositoriesUseCase(repository: UserRepository(networkClient: NetworkClient()))
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
                // Fetch user
                let user = try await fetchUserUseCase.execute(username: username)
                
                // Fetch repositories
                let repositories = try await fetchRepositoriesUseCase.execute(username: username)
                
                // Update state with results
                state = .loaded(user, repositories)
                
                // Add to search history
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
    
    public func toggleImmersiveMode() {
        // Método eliminado, mantenido como vacío para compatibilidad
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
    
    // MARK: - Funcionalidad 3D
    
    public func createRootEntity() -> Entity {
        // Método mantenido para compatibilidad
        return Entity()
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