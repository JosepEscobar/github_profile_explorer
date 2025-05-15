#if os(tvOS)
import Foundation

public final class tvOSUserProfileViewModel: UserProfileViewModel {
    @Published public var recentSearches: [String] = []
    @Published public var featuredUsers: [String] = [
        "apple", "google", "microsoft", "facebook",
        "netflix", "amazon", "spotify", "swift"
    ]
    @Published public var selectedSection: TVSection = .featured
    @Published public var showVoiceSearch: Bool = false
    
    // Use cases
    private let searchHistoryUseCase: ManageSearchHistoryUseCaseProtocol
    
    public init(
        fetchUserUseCase: FetchUserUseCaseProtocol,
        fetchRepositoriesUseCase: FetchUserRepositoriesUseCaseProtocol,
        searchHistoryUseCase: ManageSearchHistoryUseCaseProtocol
    ) {
        self.searchHistoryUseCase = searchHistoryUseCase
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
            searchHistoryUseCase: ManageSearchHistoryUseCase()
        )
    }
    
    public override func fetchUserProfile() {
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
}

public enum TVSection {
    case search
    case featured
    case recent
    case profile
    case repositories
}
#endif 