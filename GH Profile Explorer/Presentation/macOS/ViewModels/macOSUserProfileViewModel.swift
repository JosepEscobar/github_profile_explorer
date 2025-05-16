#if os(macOS)
import Foundation
import SwiftUI
import Charts

public final class macOSUserProfileViewModel: UserProfileViewModel {
    @Published public var languageStats: [LanguageStatUIModel] = []
    @Published public var selectedRepository: RepositoryUIModel?
    @Published public var searchQuery: String = ""
    @Published public var favoriteUsernames: [String] = []
    @Published public var urlToOpen: URL? = nil
    @Published public var searchHistory: [String] = []
    @Published public var userUI: UserUIModel?
    @Published public var repositoriesUI: [RepositoryUIModel] = []
    
    // Use cases
    private let calculateLanguageStatsUseCase: CalculateLanguageStatsUseCaseProtocol
    private let searchHistoryUseCase: ManageSearchHistoryUseCaseProtocol
    private let favoritesUseCase: ManageFavoritesUseCaseProtocol
    private let openURLUseCase: OpenURLUseCaseProtocol
    private let filterRepositoriesUseCase: FilterRepositoriesUseCaseProtocol
    
    public init(
        fetchUserUseCase: FetchUserUseCaseProtocol,
        fetchRepositoriesUseCase: FetchUserRepositoriesUseCaseProtocol,
        calculateLanguageStatsUseCase: CalculateLanguageStatsUseCaseProtocol,
        searchHistoryUseCase: ManageSearchHistoryUseCaseProtocol,
        favoritesUseCase: ManageFavoritesUseCaseProtocol,
        openURLUseCase: OpenURLUseCaseProtocol,
        filterRepositoriesUseCase: FilterRepositoriesUseCaseProtocol
    ) {
        self.calculateLanguageStatsUseCase = calculateLanguageStatsUseCase
        self.searchHistoryUseCase = searchHistoryUseCase
        self.favoritesUseCase = favoritesUseCase
        self.openURLUseCase = openURLUseCase
        self.filterRepositoriesUseCase = filterRepositoriesUseCase
        
        super.init(fetchUserUseCase: fetchUserUseCase, fetchRepositoriesUseCase: fetchRepositoriesUseCase)
        
        loadInitialData()
    }
    
    // Inicializador conveniente para mantener compatibilidad
    public convenience override init(
        fetchUserUseCase: FetchUserUseCaseProtocol,
        fetchRepositoriesUseCase: FetchUserRepositoriesUseCaseProtocol
    ) {
        self.init(
            fetchUserUseCase: fetchUserUseCase,
            fetchRepositoriesUseCase: fetchRepositoriesUseCase,
            calculateLanguageStatsUseCase: CalculateLanguageStatsUseCase(),
            searchHistoryUseCase: ManageSearchHistoryUseCase(),
            favoritesUseCase: ManageFavoritesUseCase(),
            openURLUseCase: OpenURLUseCase(),
            filterRepositoriesUseCase: FilterRepositoriesUseCase()
        )
    }
    
    private func loadInitialData() {
        searchHistory = searchHistoryUseCase.loadSearchHistory(for: .macOS)
        favoriteUsernames = favoritesUseCase.loadFavorites()
    }
    
    override public func fetchUserProfile() {
        super.fetchUserProfile()
    }
    
    public var filteredRepositories: [RepositoryUIModel] {
        guard !searchQuery.isEmpty else { return repositoriesUI }
        
        if case .loaded(_, let repositories) = state {
            let filteredDomainRepos = filterRepositoriesUseCase.filterBySearchText(
                repositories: repositories, 
                searchText: searchQuery
            )
            return filteredDomainRepos.map { RepositoryUIModel(from: $0) }
        }
        
        return []
    }
    
    public func handleLoadedState(user: User, repositories: [Repository]) {
        searchHistoryUseCase.addToSearchHistory(username: user.login, platform: .macOS)
        searchHistory = searchHistoryUseCase.loadSearchHistory(for: .macOS)
        
        searchQuery = ""
        selectedRepository = nil
        
        // Convertir modelos de dominio a modelos UI
        userUI = UserUIModel(from: user)
        repositoriesUI = repositories.map { RepositoryUIModel(from: $0) }
        
        // Obtener estadísticas del caso de uso y convertirlas a modelo UI
        let domainStats = calculateLanguageStatsUseCase.execute(for: repositories)
        languageStats = domainStats.map { LanguageStatUIModel(language: $0.language, count: $0.count) }
    }
    
    public func clearSearchHistory() {
        searchHistoryUseCase.clearSearchHistory(for: .macOS)
        searchHistory = []
    }
    
    public func selectFromHistory(username: String) {
        self.username = username
        Task {
            await MainActor.run {
                fetchUserProfile()
            }
        }
    }
    
    public func removeFromHistory(username: String) {
        searchHistoryUseCase.removeFromHistory(username: username, platform: .macOS)
        searchHistory = searchHistoryUseCase.loadSearchHistory(for: .macOS)
    }
    
    public func addToFavorites(username: String) {
        favoritesUseCase.addToFavorites(username: username)
        favoriteUsernames = favoritesUseCase.loadFavorites()
    }
    
    public func removeFromFavorites(username: String) {
        favoritesUseCase.removeFromFavorites(username: username)
        favoriteUsernames = favoritesUseCase.loadFavorites()
    }
    
    public func isFavorite(username: String) -> Bool {
        return favoritesUseCase.isFavorite(username: username)
    }
    
    public func toggleFavorite(username: String) {
        favoritesUseCase.toggleFavorite(username: username)
        favoriteUsernames = favoritesUseCase.loadFavorites()
    }
    
    public func openInBrowser(username: String) {
        urlToOpen = openURLUseCase.createGitHubProfileURL(for: username)
    }
    
    public func openRepositoryInBrowser(repository: RepositoryUIModel) {
        if case .loaded(_, let repositories) = state {
            if let domainRepo = repositories.first(where: { $0.id == repository.id }) {
                urlToOpen = openURLUseCase.createRepositoryURL(for: domainRepo)
            }
        }
    }
}
#endif 
