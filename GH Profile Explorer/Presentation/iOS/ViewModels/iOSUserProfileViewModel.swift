#if os(iOS)
import Foundation

// MARK: - UI Models
public final class iOSUserProfileViewModel: UserProfileViewModel {
    private enum Constants {
        enum Keys {
            static let searchHistory = "searchHistory"
        }
        
        enum Values {
            static let maxHistoryItems = 10
            static let newItemIndex = 0
        }
        
        enum URLs {
            static let githubBaseURL = "https://github.com/"
        }
        
        enum LocalizationKeys {
            static let emptyUsername = "empty_username"
        }
    }
    
    // UI Published properties
    @Published public var isShowingSearchHistory: Bool = false
    @Published public var searchHistory: [String] = []
    @Published public var navigationState: ViewState?
    @Published public var searchText: String = ""
    @Published public var selectedLanguageFilter: String? = nil
    
    // UI Model references
    @Published public var userUI: UserUIModel?
    @Published public var repositoriesUI: [RepositoryUIModel] = []
    
    private let userDefaults: UserDefaults
    
    // UI Computed properties
    public var filteredRepositoriesUI: [RepositoryUIModel] {
        var filtered = repositoriesUI
        
        // Apply text search if any
        if !searchText.isEmpty {
            filtered = filtered.filter { repo in
                repo.name.localizedCaseInsensitiveContains(searchText) ||
                (repo.description?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // Apply language filter if selected
        if let language = selectedLanguageFilter {
            filtered = filtered.filter { $0.language == language }
        }
        
        return filtered
    }
    
    public var languagesUI: [String] {
        let allLanguages = repositoriesUI.compactMap { $0.language }
        return Array(Set(allLanguages)).sorted()
    }
    
    // MARK: - Lifecycle
    
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
    
    // MARK: - Public Methods
    
    public override func fetchUserProfile() {
        guard !username.isEmpty else {
            state = .error(.unexpectedError(Constants.LocalizationKeys.emptyUsername.localized))
            return
        }
        
        super.fetchUserProfile()
        addToSearchHistory(username: username)
    }
    
    // MARK: - Private Methods
    
    private func loadSearchHistory() {
        if let history = userDefaults.stringArray(forKey: Constants.Keys.searchHistory) {
            searchHistory = history
        }
    }
    
    private func addToSearchHistory(username: String) {
        if let index = searchHistory.firstIndex(of: username) {
            searchHistory.remove(at: index)
        }
        
        searchHistory.insert(username, at: Constants.Values.newItemIndex)
        
        if searchHistory.count > Constants.Values.maxHistoryItems {
            searchHistory = Array(searchHistory.prefix(Constants.Values.maxHistoryItems))
        }
        
        userDefaults.set(searchHistory, forKey: Constants.Keys.searchHistory)
    }
    
    public func clearSearchHistory() {
        searchHistory = []
        userDefaults.removeObject(forKey: Constants.Keys.searchHistory)
    }
    
    public func selectHistoryItem(at index: Int) {
        guard index < searchHistory.count else { return }
        username = searchHistory[index]
        isShowingSearchHistory = false
        fetchUserProfile()
    }
    
    public func openGitHubProfile() -> URL? {
        guard let username = userUI?.login else { return nil }
        return URL(string: Constants.URLs.githubBaseURL + username)
    }
}
#endif 