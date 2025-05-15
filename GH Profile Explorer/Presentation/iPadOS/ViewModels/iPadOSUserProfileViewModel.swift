#if os(iOS)
import Foundation
import SwiftUI

public final class iPadOSUserProfileViewModel: UserProfileViewModel {
    private enum Constants {
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
    
    // Use cases
    private let searchHistoryUseCase: ManageSearchHistoryUseCaseProtocol
    private let openURLUseCase: OpenURLUseCaseProtocol
    private let filterRepositoriesUseCase: FilterRepositoriesUseCaseProtocol
    
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
            searchHistoryUseCase: ManageSearchHistoryUseCase(),
            openURLUseCase: OpenURLUseCase(),
            filterRepositoriesUseCase: FilterRepositoriesUseCase()
        )
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
        searchHistoryUseCase.addToSearchHistory(username: username, platform: .iPadOS)
    }
    
    private func loadSearchHistory() {
        searchHistory = searchHistoryUseCase.loadSearchHistory(for: .iPadOS)
    }
    
    public func clearSearchHistory() {
        searchHistoryUseCase.clearSearchHistory(for: .iPadOS)
        searchHistory = []
    }
    
    public func removeFromHistory(username: String) {
        searchHistoryUseCase.removeFromHistory(username: username, platform: .iPadOS)
        searchHistory = searchHistoryUseCase.loadSearchHistory(for: .iPadOS)
    }
    
    public func selectFromHistory(_ username: String) {
        self.username = username
        fetchUserProfile()
    }
    
    public func openInSafari(username: String) {
        urlToOpen = openURLUseCase.createGitHubProfileURL(for: username)
    }
    
    public func openRepositoryInSafari(_ repository: RepositoryUIModel) {
        if case .loaded(_, let repositories) = state {
            if let domainRepo = repositories.first(where: { $0.id == repository.id }) {
                urlToOpen = openURLUseCase.createRepositoryURL(for: domainRepo)
            }
        }
    }
    
    public func updateOrientation(_ orientation: DeviceOrientation) {
        self.orientation = orientation
    }
    
    public var filteredRepositories: [RepositoryUIModel] {
        guard !searchQuery.isEmpty else {
            return repositoriesUI
        }
        
        if case .loaded(_, let repositories) = state {
            let filtered = filterRepositoriesUseCase.filterBySearchText(
                repositories: repositories,
                searchText: searchQuery
            )
            return filtered.map { RepositoryUIModel(from: $0) }
        }
        
        return []
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
