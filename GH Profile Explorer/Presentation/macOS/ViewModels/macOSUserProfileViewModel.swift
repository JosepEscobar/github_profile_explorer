#if os(macOS)
import Foundation
import SwiftUI
import Charts

public final class macOSUserProfileViewModel: UserProfileViewModel {
    @Published public var languageStats: [LanguageStat] = []
    @Published public var selectedRepository: Repository?
    @Published public var searchQuery: String = ""
    @Published public var favoriteUsernames: [String] = []
    @Published public var urlToOpen: URL? = nil
    @Published public var searchHistory: [String] = []
    
    private let userDefaults: UserDefaults
    private let favoritesKey = "favoriteUsernames"
    private let historyKey = "searchHistory"
    private let maxHistoryItems = 10
    
    public override init(
        fetchUserUseCase: FetchUserUseCaseProtocol,
        fetchRepositoriesUseCase: FetchUserRepositoriesUseCaseProtocol
    ) {
        self.userDefaults = UserDefaults.standard
        super.init(fetchUserUseCase: fetchUserUseCase, fetchRepositoriesUseCase: fetchRepositoriesUseCase)
        loadFavorites()
        loadSearchHistory()
    }
    
    override public func fetchUserProfile() {
        super.fetchUserProfile()
    }
    
    public func handleLoadedState(user: User, repositories: [Repository]) {
        addToSearchHistory(username: user.login)
        searchQuery = ""
        selectedRepository = nil
        calculateLanguageStats()
    }
    
    public func calculateLanguageStats() {
        guard case let .loaded(_, repositories) = state else {
            languageStats = []
            return
        }
        
        var languageCounts: [String: Int] = [:]
        
        for repo in repositories {
            if let language = repo.language {
                languageCounts[language, default: 0] += 1
            }
        }
        
        languageStats = languageCounts.map { language, count in
            LanguageStat(language: language, count: count)
        }.sorted { $0.count > $1.count }
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
    
    public func openRepositoryInBrowser(repository: Repository) {
        urlToOpen = repository.htmlURL
    }
}

public struct LanguageStat: Identifiable {
    public var id: String { language }
    public let language: String
    public let count: Int
}
#endif 
