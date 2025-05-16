#if os(iOS)
import Foundation

// MARK: - UI Models
public final class iOSUserProfileViewModel: UserProfileViewModel {
    private enum Constants {
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
    
    // Use cases
    private let searchHistoryUseCase: ManageSearchHistoryUseCaseProtocol
    private let openURLUseCase: OpenURLUseCaseProtocol
    private let filterRepositoriesUseCase: FilterRepositoriesUseCaseProtocol
    
    // MARK: - Lifecycle
    
    public init(
        fetchUserUseCase: FetchUserUseCaseProtocol,
        fetchRepositoriesUseCase: FetchUserRepositoriesUseCaseProtocol,
        searchHistoryUseCase: ManageSearchHistoryUseCaseProtocol,
        openURLUseCase: OpenURLUseCaseProtocol,
        filterRepositoriesUseCase: FilterRepositoriesUseCaseProtocol
    ) {
        self.searchHistoryUseCase = searchHistoryUseCase
        self.openURLUseCase = openURLUseCase
        self.filterRepositoriesUseCase = filterRepositoriesUseCase
        
        super.init(fetchUserUseCase: fetchUserUseCase, fetchRepositoriesUseCase: fetchRepositoriesUseCase)
        
        loadInitialData()
    }
    
    // Convenience initializer to maintain compatibility
    public convenience override init(
        fetchUserUseCase: FetchUserUseCaseProtocol,
        fetchRepositoriesUseCase: FetchUserRepositoriesUseCaseProtocol
    ) {
        self.init(
            fetchUserUseCase: fetchUserUseCase,
            fetchRepositoriesUseCase: fetchRepositoriesUseCase,
            searchHistoryUseCase: ManageSearchHistoryUseCase(),
            openURLUseCase: OpenURLUseCase(),
            filterRepositoriesUseCase: FilterRepositoriesUseCase()
        )
    }
    
    private func loadInitialData() {
        searchHistory = searchHistoryUseCase.loadSearchHistory(for: .iOS)
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
    
    // UI Computed properties
    public var filteredRepositoriesUI: [RepositoryUIModel] {
        if case .loaded(_, let repositories) = state {
            let filtered = filterRepositoriesUseCase.filterBySearchTextAndLanguage(
                repositories: repositories,
                searchText: searchText,
                language: selectedLanguageFilter
            )
            return filtered.map { RepositoryUIModel(from: $0) }
        }
        return []
    }
    
    public var languagesUI: [String] {
        if case .loaded(_, let repositories) = state {
            return filterRepositoriesUseCase.extractUniqueLanguages(from: repositories)
        }
        return []
    }
    
    // MARK: - Public Methods
    
    public override func fetchUserProfile() {
        guard !username.isEmpty else {
            state = .error(.unexpectedError(Constants.LocalizationKeys.emptyUsername.localized))
            return
        }
        
        super.fetchUserProfile()
        searchHistoryUseCase.addToSearchHistory(username: username, platform: .iOS)
        searchHistory = searchHistoryUseCase.loadSearchHistory(for: .iOS)
    }
    
    public func clearSearchHistory() {
        searchHistoryUseCase.clearSearchHistory(for: .iOS)
        searchHistory = []
    }
    
    public func selectHistoryItem(at index: Int) {
        guard index < searchHistory.count else { return }
        username = searchHistory[index]
        isShowingSearchHistory = false
        fetchUserProfile()
    }
    
    public func openGitHubProfile() -> URL? {
        guard let username = userUI?.login else { return nil }
        return openURLUseCase.createGitHubProfileURL(for: username)
    }
}
#endif 