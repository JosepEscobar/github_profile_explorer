#if os(visionOS)
import Foundation
import RealityKit
import SwiftUI

public final class VisionOSUserProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public var username: String = ""
    @Published public var state: ViewState = .initial
    @Published public var isShowingSearchHistory: Bool = false
    @Published public var searchHistory: [String] = []
    @Published public var isInImmersiveSpace: Bool = false
    @Published public var needsSceneUpdate: Bool = false
    @Published public var searchQuery: String = ""
    @Published public var selectedLanguageFilter: String? = nil
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
        if !searchQuery.isEmpty || selectedLanguageFilter != nil {
            return filterRepositoriesUseCase.filterBySearchTextAndLanguage(
                repositories: repositoriesUI,
                searchText: searchQuery,
                language: selectedLanguageFilter
            )
        }
        return repositoriesUI
    }
    
    public var uniqueLanguages: [String] {
        return filterRepositoriesUseCase.extractUniqueLanguages(from: repositoriesUI)
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
                if let apiError = error as? APIError {
                    state = .error(apiError)
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
        manageSearchHistoryUseCase?.removeFromSearchHistory(username: item, platform: .visionOS)
        loadSearchHistory()
    }
    
    public func toggleImmersiveMode() {
        isInImmersiveSpace.toggle()
    }
    
    public func setSearchQuery(_ query: String) {
        searchQuery = query
    }
    
    public func setLanguageFilter(_ language: String?) {
        selectedLanguageFilter = language
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
    
    public func configureImmersiveSpaceUpdates() {
        // Configurar observador para actualizaciones
        Task { @MainActor in
            for await _ in NotificationCenter.default.notifications(named: NSNotification.Name("UpdateImmersiveSpaceData")) {
                self.needsSceneUpdate = true
            }
        }
    }
    
    public func createRootEntity() -> Entity {
        // Usamos el factory para crear la entidad raíz
        return VisionOSEntityFactory.createRootEntity(user: user, repositories: repositories)
    }
}

// MARK: - Estados de la vista
public enum ViewState {
    case initial
    case loading
    case loaded(User, [Repository])
    case error(APIError)
}
#endif 