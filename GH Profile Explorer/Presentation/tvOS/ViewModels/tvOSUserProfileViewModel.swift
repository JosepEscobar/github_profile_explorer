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
    
    private let userDefaults: UserDefaults
    private let recentSearchesKey = "tvOSRecentSearches"
    private let maxRecentSearches = 5
    
    public override init(
        fetchUserUseCase: FetchUserUseCaseProtocol,
        fetchRepositoriesUseCase: FetchUserRepositoriesUseCaseProtocol
    ) {
        self.userDefaults = UserDefaults.standard
        super.init(fetchUserUseCase: fetchUserUseCase, fetchRepositoriesUseCase: fetchRepositoriesUseCase)
        loadRecentSearches()
    }
    
    public override func fetchUserProfile() {
        super.fetchUserProfile()
        addToRecentSearches(username: username)
    }
    
    private func loadRecentSearches() {
        if let searches = userDefaults.stringArray(forKey: recentSearchesKey) {
            recentSearches = searches
        }
    }
    
    public func addToRecentSearches(username: String) {
        guard !username.isEmpty else { return }
        
        // Remove if exists
        if let index = recentSearches.firstIndex(of: username) {
            recentSearches.remove(at: index)
        }
        
        // Add to the beginning
        recentSearches.insert(username, at: 0)
        
        // Limit to max items
        if recentSearches.count > maxRecentSearches {
            recentSearches = Array(recentSearches.prefix(maxRecentSearches))
        }
        
        // Save
        userDefaults.set(recentSearches, forKey: recentSearchesKey)
    }
    
    public func selectFeaturedUser(_ username: String) {
        self.username = username
        fetchUserProfile()
    }
    
    public func clearRecentSearches() {
        recentSearches = []
        userDefaults.removeObject(forKey: recentSearchesKey)
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