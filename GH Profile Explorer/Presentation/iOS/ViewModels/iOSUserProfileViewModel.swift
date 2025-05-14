#if os(iOS)
import Foundation

public final class iOSUserProfileViewModel: UserProfileViewModel {
    @Published public var isShowingSearchHistory: Bool = false
    @Published public var searchHistory: [String] = []
    @Published public var navigationState: ViewState?
    
    private let userDefaults: UserDefaults
    private let historyKey = "searchHistory"
    private let maxHistoryItems = 10
    
    public override init(
        fetchUserUseCase: FetchUserUseCaseProtocol,
        fetchRepositoriesUseCase: FetchUserRepositoriesUseCaseProtocol
    ) {
        self.userDefaults = UserDefaults.standard
        super.init(fetchUserUseCase: fetchUserUseCase, fetchRepositoriesUseCase: fetchRepositoriesUseCase)
        loadSearchHistory()
    }
    
    public override func fetchUserProfile() {
        guard !username.isEmpty else {
            state = .error(.unexpectedError("Username cannot be empty"))
            return
        }
        
        super.fetchUserProfile()
        addToSearchHistory(username: username)
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
    
    public func selectHistoryItem(at index: Int) {
        guard index < searchHistory.count else { return }
        username = searchHistory[index]
        isShowingSearchHistory = false
        fetchUserProfile()
    }
} 
#endif 