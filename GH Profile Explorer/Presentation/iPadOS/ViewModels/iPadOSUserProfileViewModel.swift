#if os(iOS)
import Foundation
import SwiftUI

public final class iPadOSUserProfileViewModel: UserProfileViewModel {
    @Published public var searchHistory: [String] = []
    @Published public var isDetailExpanded: Bool = true
    @Published public var selectedRepository: Repository?
    @Published public var searchQuery: String = ""
    @Published public var isSearching: Bool = false
    @Published public var showUserQRCode: Bool = false
    @Published public var orientation: DeviceOrientation = .portrait
    @Published public var urlToOpen: URL? = nil
    
    private let userDefaults: UserDefaults
    private let historyKey = "iPadSearchHistory"
    private let maxHistoryItems = 15
    
    public override init(
        fetchUserUseCase: FetchUserUseCaseProtocol,
        fetchRepositoriesUseCase: FetchUserRepositoriesUseCaseProtocol
    ) {
        self.userDefaults = UserDefaults.standard
        super.init(fetchUserUseCase: fetchUserUseCase, fetchRepositoriesUseCase: fetchRepositoriesUseCase)
        loadSearchHistory()
    }
    
    public override func fetchUserProfile() {
        super.fetchUserProfile()
        addToSearchHistory(username: username)
    }
    
    private func loadSearchHistory() {
        if let history = userDefaults.stringArray(forKey: historyKey) {
            searchHistory = history
        }
    }
    
    private func addToSearchHistory(username: String) {
        guard !username.isEmpty else { return }
        
        // Remove if exists
        if let index = searchHistory.firstIndex(of: username) {
            searchHistory.remove(at: index)
        }
        
        // Add to the beginning
        searchHistory.insert(username, at: 0)
        
        // Limit to max items
        if searchHistory.count > maxHistoryItems {
            searchHistory = Array(searchHistory.prefix(maxHistoryItems))
        }
        
        // Save
        userDefaults.set(searchHistory, forKey: historyKey)
    }
    
    public func clearSearchHistory() {
        searchHistory = []
        userDefaults.removeObject(forKey: historyKey)
    }
    
    public func saveSearchHistory() {
        userDefaults.set(searchHistory, forKey: historyKey)
    }
    
    public func removeFromHistory(username: String) {
        if let index = searchHistory.firstIndex(of: username) {
            searchHistory.remove(at: index)
            saveSearchHistory()
        }
    }
    
    public func selectFromHistory(_ username: String) {
        self.username = username
        fetchUserProfile()
    }
    
    public func openInSafari(username: String) {
        if let url = URL(string: "https://github.com/\(username)") {
            urlToOpen = url
        }
    }
    
    public func openRepositoryInSafari(_ repository: Repository) {
        urlToOpen = repository.htmlURL
    }
    
    public func updateOrientation(_ orientation: DeviceOrientation) {
        self.orientation = orientation
    }
    
    public var filteredRepositories: [Repository] {
        guard case let .loaded(_, repositories) = state else {
            return []
        }
        
        guard !searchQuery.isEmpty else {
            return repositories
        }
        
        return repositories.filter { repo in
            repo.name.localizedCaseInsensitiveContains(searchQuery) ||
            (repo.description?.localizedCaseInsensitiveContains(searchQuery) ?? false) ||
            (repo.language?.localizedCaseInsensitiveContains(searchQuery) ?? false)
        }
    }
}

public enum DeviceOrientation {
    case portrait
    case landscape
}
#endif 
