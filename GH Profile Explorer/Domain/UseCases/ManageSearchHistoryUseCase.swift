import Foundation

public protocol ManageSearchHistoryUseCaseProtocol {
    func loadSearchHistory(for platform: Platform) -> [String]
    func addToSearchHistory(username: String, platform: Platform)
    func removeFromHistory(username: String, platform: Platform)
    func clearSearchHistory(for platform: Platform)
}

public final class ManageSearchHistoryUseCase: ManageSearchHistoryUseCaseProtocol {
    private let userDefaults: UserDefaults
    
    private enum Constants {
        enum Keys {
            static let iosSearchHistory = "searchHistory"
            static let ipadSearchHistory = "iPadSearchHistory"
            static let macSearchHistory = "macSearchHistory"
            static let tvSearchHistory = "tvOSRecentSearches"
            static let visionSearchHistory = "visionSearchHistory"
        }
        
        enum Values {
            static let iosMaxHistoryItems = 10
            static let ipadMaxHistoryItems = 15
            static let macMaxHistoryItems = 10
            static let tvMaxHistoryItems = 5
            static let visionMaxHistoryItems = 10
        }
    }
    
    public init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
    
    public func loadSearchHistory(for platform: Platform) -> [String] {
        let key = historyKey(for: platform)
        return userDefaults.stringArray(forKey: key) ?? []
    }
    
    public func addToSearchHistory(username: String, platform: Platform) {
        guard !username.isEmpty else { return }
        
        let key = historyKey(for: platform)
        var history = userDefaults.stringArray(forKey: key) ?? []
        
        // Remove if already exists
        if let index = history.firstIndex(of: username) {
            history.remove(at: index)
        }
        
        // Add to beginning
        history.insert(username, at: 0)
        
        // Limit to max items
        let maxItems = maxHistoryItems(for: platform)
        if history.count > maxItems {
            history = Array(history.prefix(maxItems))
        }
        
        // Save
        userDefaults.set(history, forKey: key)
    }
    
    public func removeFromHistory(username: String, platform: Platform) {
        let key = historyKey(for: platform)
        var history = userDefaults.stringArray(forKey: key) ?? []
        
        // Si no está en el historial, no hacemos nada
        if !history.contains(username) {
            return
        }
        
        if let index = history.firstIndex(of: username) {
            history.remove(at: index)
            userDefaults.set(history, forKey: key)
        }
    }
    
    public func clearSearchHistory(for platform: Platform) {
        let key = historyKey(for: platform)
        userDefaults.removeObject(forKey: key)
    }
    
    // MARK: - Private Helpers
    
    private func historyKey(for platform: Platform) -> String {
        switch platform {
        case .iOS:
            return Constants.Keys.iosSearchHistory
        case .iPadOS:
            return Constants.Keys.ipadSearchHistory
        case .macOS:
            return Constants.Keys.macSearchHistory
        case .tvOS:
            return Constants.Keys.tvSearchHistory
        case .visionOS:
            return Constants.Keys.visionSearchHistory
        }
    }
    
    private func maxHistoryItems(for platform: Platform) -> Int {
        switch platform {
        case .iOS:
            return Constants.Values.iosMaxHistoryItems
        case .iPadOS:
            return Constants.Values.ipadMaxHistoryItems
        case .macOS:
            return Constants.Values.macMaxHistoryItems
        case .tvOS:
            return Constants.Values.tvMaxHistoryItems
        case .visionOS:
            return Constants.Values.visionMaxHistoryItems
        }
    }
}

public enum Platform {
    case iOS
    case iPadOS
    case macOS
    case tvOS
    case visionOS
} 