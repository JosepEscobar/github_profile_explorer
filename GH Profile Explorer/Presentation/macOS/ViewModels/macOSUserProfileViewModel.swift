import Foundation
import SwiftUI
import Charts

public final class macOSUserProfileViewModel: UserProfileViewModel {
    @Published public var languageStats: [LanguageStat] = []
    @Published public var selectedRepository: Repository?
    @Published public var searchQuery: String = ""
    @Published public var favoriteUsernames: [String] = []
    @Published public var urlToOpen: URL? = nil
    
    private let userDefaults: UserDefaults
    private let favoritesKey = "favoriteUsernames"
    
    public override init(
        fetchUserUseCase: FetchUserUseCaseProtocol,
        fetchRepositoriesUseCase: FetchUserRepositoriesUseCaseProtocol
    ) {
        self.userDefaults = UserDefaults.standard
        super.init(fetchUserUseCase: fetchUserUseCase, fetchRepositoriesUseCase: fetchRepositoriesUseCase)
        loadFavorites()
    }
    
    public override func fetchUserProfile() {
        guard !username.isEmpty else {
            state = .error(.unexpectedError("Username cannot be empty"))
            return
        }
        
        super.fetchUserProfile()
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
        if let url = URL(string: "https://github.com/\(username)") {
            urlToOpen = url
        }
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
