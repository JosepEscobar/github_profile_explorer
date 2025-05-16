#if os(tvOS)
import Foundation
import SwiftUI

public final class tvOSUserProfileViewModel: UserProfileViewModel {
    private enum Constants {
        enum Featured {
            static let defaultUsers = [
                "apple", "josepescobar", "microsoft", "facebook",
                "netflix", "amazon", "spotify", "swift"
            ]
        }
        
        enum Strings {
            static let emptyUsername = "empty_username"
        }
    }
    
    @Published public var recentSearches: [String] = []
    @Published public var featuredUsers: [String] = Constants.Featured.defaultUsers
    @Published public var selectedSection: TVSection = .featured
    @Published public var showVoiceSearch: Bool = false
    
    // UI Models
    @Published public var userUI: UserUIModel?
    @Published public var repositoriesUI: [RepositoryUIModel] = []
    
    // Use cases
    private let searchHistoryUseCase: ManageSearchHistoryUseCaseProtocol
    private let filterRepositoriesUseCase: FilterRepositoriesUseCaseProtocol
    private let openURLUseCase: OpenURLUseCaseProtocol
    
    public init(
        fetchUserUseCase: FetchUserUseCaseProtocol,
        fetchRepositoriesUseCase: FetchUserRepositoriesUseCaseProtocol,
        searchHistoryUseCase: ManageSearchHistoryUseCaseProtocol,
        filterRepositoriesUseCase: FilterRepositoriesUseCaseProtocol,
        openURLUseCase: OpenURLUseCaseProtocol
    ) {
        self.searchHistoryUseCase = searchHistoryUseCase
        self.filterRepositoriesUseCase = filterRepositoriesUseCase
        self.openURLUseCase = openURLUseCase
        
        super.init(fetchUserUseCase: fetchUserUseCase, fetchRepositoriesUseCase: fetchRepositoriesUseCase)
        loadRecentSearches()
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
            filterRepositoriesUseCase: FilterRepositoriesUseCase(),
            openURLUseCase: OpenURLUseCase()
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
        guard !username.isEmpty else {
            state = .error(.unexpectedError(Constants.Strings.emptyUsername.localized))
            return
        }
        
        super.fetchUserProfile()
        searchHistoryUseCase.addToSearchHistory(username: username, platform: .tvOS)
        loadRecentSearches()
    }
    
    private func loadRecentSearches() {
        recentSearches = searchHistoryUseCase.loadSearchHistory(for: .tvOS)
    }
    
    public func selectFeaturedUser(_ username: String) {
        self.username = username
        fetchUserProfile()
    }
    
    public func clearRecentSearches() {
        searchHistoryUseCase.clearSearchHistory(for: .tvOS)
        recentSearches = []
    }
    
    public func getGitHubProfileURL(for username: String) -> URL? {
        return openURLUseCase.createGitHubProfileURL(for: username)
    }
    
    public func getRepositoryURL(for repository: RepositoryUIModel) -> URL? {
        if case .loaded(_, let repositories) = state {
            if let domainRepo = repositories.first(where: { $0.id == repository.id }) {
                return openURLUseCase.createRepositoryURL(for: domainRepo)
            }
        }
        return nil
    }
    
    public var uniqueLanguages: [String] {
        if case .loaded(_, let repositories) = state {
            return filterRepositoriesUseCase.extractUniqueLanguages(from: repositories)
        }
        return []
    }
}

public enum TVSection {
    case search
    case featured
    case recent
    case profile
    case repositories
}
#endif 
