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
    
    private let calculateLanguageStatsUseCase: CalculateLanguageStatsUseCaseProtocol
    private let userDefaults: UserDefaults
    private let favoritesKey = "favoriteUsernames"
    private let historyKey = "searchHistory"
    private let maxHistoryItems = 10
    
    public init(
        fetchUserUseCase: FetchUserUseCaseProtocol,
        fetchRepositoriesUseCase: FetchUserRepositoriesUseCaseProtocol,
        calculateLanguageStatsUseCase: CalculateLanguageStatsUseCaseProtocol
    ) {
        self.calculateLanguageStatsUseCase = calculateLanguageStatsUseCase
        self.userDefaults = UserDefaults.standard
        super.init(fetchUserUseCase: fetchUserUseCase, fetchRepositoriesUseCase: fetchRepositoriesUseCase)
        loadFavorites()
        loadSearchHistory()
    }
    
    // Inicializador conveniente para mantener compatibilidad
    public convenience override init(
        fetchUserUseCase: FetchUserUseCaseProtocol,
        fetchRepositoriesUseCase: FetchUserRepositoriesUseCaseProtocol
    ) {
        self.init(
            fetchUserUseCase: fetchUserUseCase,
            fetchRepositoriesUseCase: fetchRepositoriesUseCase,
            calculateLanguageStatsUseCase: CalculateLanguageStatsUseCase()
        )
    }
    
    override public func fetchUserProfile() {
        super.fetchUserProfile()
    }
    
    public var filteredRepositories: [RepositoryUIModel] {
        guard !searchQuery.isEmpty else { return repositoriesUI }
        return repositoriesUI.filter { repo in
            repo.name.localizedCaseInsensitiveContains(searchQuery) ||
            (repo.description?.localizedCaseInsensitiveContains(searchQuery) ?? false)
        }
    }
    
    public func handleLoadedState(user: User, repositories: [Repository]) {
        addToSearchHistory(username: user.login)
        searchQuery = ""
        selectedRepository = nil
        
        // Convertir modelos de dominio a modelos UI
        userUI = UserUIModel(from: user)
        repositoriesUI = repositories.map { RepositoryUIModel(from: $0) }
        
        // Obtener estadísticas del caso de uso y convertirlas a modelo UI
        let domainStats = calculateLanguageStatsUseCase.execute(for: repositories)
        languageStats = domainStats.map { LanguageStatUIModel(language: $0.language, count: $0.count) }
    }
    
    private func loadFavorites() {
        if let favorites = userDefaults.stringArray(forKey: favoritesKey) {
            favoriteUsernames = favorites
        }
    }
    
    private func loadSearchHistory() {
        if let history = userDefaults.stringArray(forKey: historyKey) {
            searchHistory = history
        }
    }
    
    private func addToSearchHistory(username: String) {
        if let index = searchHistory.firstIndex(of: username) {
            searchHistory.remove(at: index)
        }
        
        searchHistory.insert(username, at: 0)
        
        if searchHistory.count > maxHistoryItems {
            searchHistory = Array(searchHistory.prefix(maxHistoryItems))
        }
        
        userDefaults.set(searchHistory, forKey: historyKey)
    }
    
    public func clearSearchHistory() {
        searchHistory = []
        userDefaults.removeObject(forKey: historyKey)
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
        if let index = searchHistory.firstIndex(of: username) {
            searchHistory.remove(at: index)
            userDefaults.set(searchHistory, forKey: historyKey)
        }
    }
    
    public func addToFavorites(username: String) {
        if !favoriteUsernames.contains(username) {
            favoriteUsernames.append(username)
            userDefaults.set(favoriteUsernames, forKey: favoritesKey)
        }
    }
    
    public func removeFromFavorites(username: String) {
        if let index = favoriteUsernames.firstIndex(of: username) {
            favoriteUsernames.remove(at: index)
            userDefaults.set(favoriteUsernames, forKey: favoritesKey)
        }
    }
    
    public func isFavorite(username: String) -> Bool {
        return favoriteUsernames.contains(username)
    }
    
    public func toggleFavorite(username: String) {
        if isFavorite(username: username) {
            removeFromFavorites(username: username)
        } else {
            addToFavorites(username: username)
        }
    }
    
    public func openInBrowser(username: String) {
        guard let url = URL(string: "https://github.com/\(username)") else { 
            return 
        }
        
        urlToOpen = url
    }
    
    public func openRepositoryInBrowser(repository: RepositoryUIModel) {
        urlToOpen = repository.htmlURL
    }
}
#endif 
