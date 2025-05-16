import Quick
import Nimble
import Foundation
@testable import GH_Profile_Explorer

class ManageFavoritesUseCaseTests: QuickSpec {
    override class func spec() {
        var manageFavoritesUseCase: ManageFavoritesUseCase!
        var mockUserDefaults: FavoritesMockUserDefaults!
        
        beforeEach {
            mockUserDefaults = FavoritesMockUserDefaults()
            manageFavoritesUseCase = ManageFavoritesUseCase(userDefaults: mockUserDefaults)
        }
        
        describe("ManageFavoritesUseCase") {
            context("when loading favorites") {
                it("should return an empty array when no favorites exist") {
                    // When
                    let favorites = manageFavoritesUseCase.loadFavorites()
                    
                    // Then
                    expect(favorites).to(beEmpty())
                }
                
                it("should return existing favorites") {
                    // Given
                    let existingFavorites = ["user1", "user2", "user3"]
                    mockUserDefaults.mockStringArray = existingFavorites
                    
                    // When
                    let favorites = manageFavoritesUseCase.loadFavorites()
                    
                    // Then
                    expect(favorites).to(equal(existingFavorites))
                }
            }
            
            context("when adding a favorite") {
                it("should add a new username to favorites") {
                    // Given
                    mockUserDefaults.mockStringArray = []
                    
                    // When
                    manageFavoritesUseCase.addToFavorites(username: "newuser")
                    
                    // Then
                    expect(mockUserDefaults.storedStringArray).to(equal(["newuser"]))
                }
                
                it("should not add a duplicate username") {
                    // Given
                    mockUserDefaults.mockStringArray = ["existinguser"]
                    mockUserDefaults.wasSetCalled = false
                    
                    // When
                    manageFavoritesUseCase.addToFavorites(username: "existinguser")
                    
                    // Then
                    // Si el username ya existe, no se debe llamar a set()
                    expect(mockUserDefaults.wasSetCalled).to(beFalse())
                }
            }
            
            context("when removing a favorite") {
                it("should remove an existing username from favorites") {
                    // Given
                    mockUserDefaults.mockStringArray = ["user1", "user2", "user3"]
                    
                    // When
                    manageFavoritesUseCase.removeFromFavorites(username: "user2")
                    
                    // Then
                    expect(mockUserDefaults.storedStringArray).to(equal(["user1", "user3"]))
                }
                
                it("should do nothing when removing a non-existent username") {
                    // Given
                    mockUserDefaults.mockStringArray = ["user1", "user3"]
                    mockUserDefaults.wasSetCalled = false
                    
                    // When
                    manageFavoritesUseCase.removeFromFavorites(username: "user2")
                    
                    // Then
                    // Si el username no existe, no se debe llamar a set()
                    expect(mockUserDefaults.wasSetCalled).to(beFalse())
                }
            }
            
            context("when checking if a username is a favorite") {
                it("should return true for an existing favorite") {
                    // Given
                    mockUserDefaults.mockStringArray = ["user1", "user2", "user3"]
                    
                    // When
                    let isFavorite = manageFavoritesUseCase.isFavorite(username: "user2")
                    
                    // Then
                    expect(isFavorite).to(beTrue())
                }
                
                it("should return false for a non-favorite username") {
                    // Given
                    mockUserDefaults.mockStringArray = ["user1", "user3"]
                    
                    // When
                    let isFavorite = manageFavoritesUseCase.isFavorite(username: "user2")
                    
                    // Then
                    expect(isFavorite).to(beFalse())
                }
            }
            
            context("when toggling a favorite") {
                it("should add a username that is not a favorite") {
                    // Given
                    mockUserDefaults.mockStringArray = ["user1", "user3"]
                    
                    // When
                    manageFavoritesUseCase.toggleFavorite(username: "user2")
                    
                    // Then
                    expect(mockUserDefaults.storedStringArray).to(equal(["user1", "user3", "user2"]))
                }
                
                it("should remove a username that is already a favorite") {
                    // Given
                    mockUserDefaults.mockStringArray = ["user1", "user2", "user3"]
                    
                    // When
                    manageFavoritesUseCase.toggleFavorite(username: "user2")
                    
                    // Then
                    expect(mockUserDefaults.storedStringArray).to(equal(["user1", "user3"]))
                }
            }
        }
    }
}

class FavoritesMockUserDefaults: UserDefaults {
    var mockStringArray: [String]?
    var storedStringArray: [String]?
    var wasSetCalled = false
    
    override func stringArray(forKey defaultName: String) -> [String]? {
        return mockStringArray
    }
    
    override func set(_ value: Any?, forKey defaultName: String) {
        wasSetCalled = true
        if let stringArray = value as? [String] {
            storedStringArray = stringArray
        }
    }
}
