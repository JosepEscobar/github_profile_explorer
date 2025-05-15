#if os(iOS)
import Foundation
import SwiftUI

public final class iPadOSUserProfileViewModel: UserProfileViewModel {
    private enum Constants {
        enum Keys {
            static let searchHistory = "iPadSearchHistory"
        }
        
        enum Values {
            static let maxHistoryItems = 15
            static let defaultIndex = 0
        }
        
        enum URLs {
            static let githubBaseURL = "https://github.com/"
        }
        
        enum Layout {
            static let largeScreenWidth = 1000.0
        }
    }
    
    @Published public var searchHistory: [String] = []
    @Published public var isDetailExpanded: Bool = true
    @Published public var selectedRepository: RepositoryUIModel?
    @Published public var searchQuery: String = ""
    @Published public var isSearching: Bool = false
    @Published public var showUserQRCode: Bool = false
    @Published public var orientation: DeviceOrientation = .portrait
    @Published public var urlToOpen: URL? = nil
    
    // UI Model references
    @Published public var userUI: UserUIModel?
    @Published public var repositoriesUI: [RepositoryUIModel] = []
    
    private let userDefaults: UserDefaults
    
    public override init(
        fetchUserUseCase: FetchUserUseCaseProtocol,
        fetchRepositoriesUseCase: FetchUserRepositoriesUseCaseProtocol
    ) {
        self.userDefaults = UserDefaults.standard
        super.init(fetchUserUseCase: fetchUserUseCase, fetchRepositoriesUseCase: fetchRepositoriesUseCase)
        loadSearchHistory()
    }
    
    // Override state property to update UI models when it changes
    public override var state: ViewState {
        didSet {
            Task { @MainActor in
                updateUIModels()
            }
        }
    }
    
    // Method to update UI models based on current state
    @MainActor
    private func updateUIModels() {
        switch state {
        case .loaded(let user, let repositories):
            self.userUI = UserUIModel(from: user)
            self.repositoriesUI = repositories.map { RepositoryUIModel(from: $0) }
        case .idle, .loading, .error:
            self.userUI = nil
            self.repositoriesUI = []
        }
    }
    
    public override func fetchUserProfile() {
        super.fetchUserProfile()
        addToSearchHistory(username: username)
    }
    
    private func loadSearchHistory() {
        if let history = userDefaults.stringArray(forKey: Constants.Keys.searchHistory) {
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
        searchHistory.insert(username, at: Constants.Values.defaultIndex)
        
        // Limit to max items
        if searchHistory.count > Constants.Values.maxHistoryItems {
            searchHistory = Array(searchHistory.prefix(Constants.Values.maxHistoryItems))
        }
        
        // Save
        userDefaults.set(searchHistory, forKey: Constants.Keys.searchHistory)
    }
    
    public func clearSearchHistory() {
        searchHistory = []
        userDefaults.removeObject(forKey: Constants.Keys.searchHistory)
    }
    
    public func saveSearchHistory() {
        userDefaults.set(searchHistory, forKey: Constants.Keys.searchHistory)
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
        if let url = URL(string: Constants.URLs.githubBaseURL + username) {
            urlToOpen = url
        }
    }
    
    public func openRepositoryInSafari(_ repository: RepositoryUIModel) {
        urlToOpen = repository.htmlURL
    }
    
    public func updateOrientation(_ orientation: DeviceOrientation) {
        self.orientation = orientation
    }
    
    public var filteredRepositories: [RepositoryUIModel] {
        guard !searchQuery.isEmpty else {
            return repositoriesUI
        }
        
        return repositoriesUI.filter { repo in
            repo.name.localizedCaseInsensitiveContains(searchQuery) ||
            (repo.description?.localizedCaseInsensitiveContains(searchQuery) ?? false) ||
            (repo.language?.localizedCaseInsensitiveContains(searchQuery) ?? false)
        }
    }
    
    public var currentUser: UserUIModel? {
        return userUI
    }
}

public enum DeviceOrientation {
    case portrait
    case landscape
}
#endif 
