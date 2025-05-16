import Foundation

public protocol ManageFavoritesUseCaseProtocol {
    func loadFavorites() -> [String]
    func addToFavorites(username: String)
    func removeFromFavorites(username: String)
    func isFavorite(username: String) -> Bool
    func toggleFavorite(username: String)
}

public final class ManageFavoritesUseCase: ManageFavoritesUseCaseProtocol {
    private let userDefaults: UserDefaults
    private let favoritesKey = "favoriteUsernames"
    
    public init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
    
    public func loadFavorites() -> [String] {
        return userDefaults.stringArray(forKey: favoritesKey) ?? []
    }
    
    public func addToFavorites(username: String) {
        var favorites = loadFavorites()
        
        // If already in favorites, do nothing
        if favorites.contains(username) {
            return
        }
        
        favorites.append(username)
        userDefaults.set(favorites, forKey: favoritesKey)
    }
    
    public func removeFromFavorites(username: String) {
        var favorites = loadFavorites()
        
        // If not in favorites, do nothing
        if !favorites.contains(username) {
            return
        }
        
        if let index = favorites.firstIndex(of: username) {
            favorites.remove(at: index)
            userDefaults.set(favorites, forKey: favoritesKey)
        }
    }
    
    public func isFavorite(username: String) -> Bool {
        let favorites = loadFavorites()
        return favorites.contains(username)
    }
    
    public func toggleFavorite(username: String) {
        if isFavorite(username: username) {
            removeFromFavorites(username: username)
        } else {
            addToFavorites(username: username)
        }
    }
} 