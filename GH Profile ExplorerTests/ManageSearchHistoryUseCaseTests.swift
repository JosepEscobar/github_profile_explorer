import Quick
import Nimble
import Foundation
@testable import GH_Profile_Explorer

class ManageSearchHistoryUseCaseTests: QuickSpec {
    override class func spec() {
        var manageSearchHistoryUseCase: ManageSearchHistoryUseCase!
        var mockUserDefaults: HistoryMockUserDefaults!
        
        beforeEach {
            mockUserDefaults = HistoryMockUserDefaults()
            manageSearchHistoryUseCase = ManageSearchHistoryUseCase(userDefaults: mockUserDefaults)
        }
        
        describe("ManageSearchHistoryUseCase") {
            context("when loading search history") {
                it("should return an empty array when no history exists") {
                    // When
                    let history = manageSearchHistoryUseCase.loadSearchHistory(for: .iOS)
                    
                    // Then
                    expect(history).to(beEmpty())
                }
                
                it("should return existing history") {
                    // Given
                    let existingHistory = ["user1", "user2", "user3"]
                    mockUserDefaults.mockStringArray = existingHistory
                    
                    // When
                    let history = manageSearchHistoryUseCase.loadSearchHistory(for: .iOS)
                    
                    // Then
                    expect(history).to(equal(existingHistory))
                }
            }
            
            context("when adding to search history") {
                it("should add a new username to empty history") {
                    // Given
                    mockUserDefaults.mockStringArray = []
                    
                    // When
                    manageSearchHistoryUseCase.addToSearchHistory(username: "newuser", platform: .iOS)
                    
                    // Then
                    expect(mockUserDefaults.storedStringArray).to(equal(["newuser"]))
                }
                
                it("should add username to the beginning of existing history") {
                    // Given
                    mockUserDefaults.mockStringArray = ["user1", "user2"]
                    
                    // When
                    manageSearchHistoryUseCase.addToSearchHistory(username: "newuser", platform: .iOS)
                    
                    // Then
                    expect(mockUserDefaults.storedStringArray).to(equal(["newuser", "user1", "user2"]))
                }
                
                it("should move existing username to the beginning") {
                    // Given
                    mockUserDefaults.mockStringArray = ["user1", "user2", "user3"]
                    
                    // When
                    manageSearchHistoryUseCase.addToSearchHistory(username: "user2", platform: .iOS)
                    
                    // Then
                    expect(mockUserDefaults.storedStringArray).to(equal(["user2", "user1", "user3"]))
                }
                
                it("should limit history to maximum items for iOS") {
                    // Given
                    // Create a history with more than the max items
                    var longHistory: [String] = []
                    for i in 1...15 {
                        longHistory.append("user\(i)")
                    }
                    mockUserDefaults.mockStringArray = longHistory
                    
                    // When
                    manageSearchHistoryUseCase.addToSearchHistory(username: "newuser", platform: .iOS)
                    
                    // Then
                    expect(mockUserDefaults.storedStringArray?.count).to(equal(10)) // iOS max is 10
                    expect(mockUserDefaults.storedStringArray?[0]).to(equal("newuser"))
                }
                
                it("should not add empty username") {
                    // Given
                    mockUserDefaults.mockStringArray = ["user1", "user2"]
                    
                    // When
                    manageSearchHistoryUseCase.addToSearchHistory(username: "", platform: .iOS)
                    
                    // Then
                    expect(mockUserDefaults.storedStringArray).to(beNil())
                }
            }
            
            context("when removing from history") {
                it("should remove an existing username from history") {
                    // Given
                    mockUserDefaults.mockStringArray = ["user1", "user2", "user3"]
                    
                    // When
                    manageSearchHistoryUseCase.removeFromHistory(username: "user2", platform: .iOS)
                    
                    // Then
                    expect(mockUserDefaults.storedStringArray).to(equal(["user1", "user3"]))
                }
                
                it("should do nothing when removing a non-existent username") {
                    // Given
                    mockUserDefaults.mockStringArray = ["user1", "user3"]
                    mockUserDefaults.wasSetCalled = false
                    
                    // When
                    manageSearchHistoryUseCase.removeFromHistory(username: "user2", platform: .iOS)
                    
                    // Then
                    // Si el username no existe, no se debe llamar a set()
                    expect(mockUserDefaults.wasSetCalled).to(beFalse())
                }
            }
            
            context("when clearing search history") {
                it("should remove the entire history") {
                    // Given
                    mockUserDefaults.mockStringArray = ["user1", "user2", "user3"]
                    
                    // When
                    manageSearchHistoryUseCase.clearSearchHistory(for: .iOS)
                    
                    // Then
                    expect(mockUserDefaults.removedKey).toNot(beNil())
                }
            }
            
            context("when handling different platforms") {
                it("should use different keys for different platforms") {
                    // Given
                    mockUserDefaults.mockStringArray = []
                    
                    // When - Add to iOS history
                    manageSearchHistoryUseCase.addToSearchHistory(username: "iosuser", platform: .iOS)
                    let iosKey = mockUserDefaults.lastUsedKey
                    
                    // Then add to macOS history
                    manageSearchHistoryUseCase.addToSearchHistory(username: "macuser", platform: .macOS)
                    let macKey = mockUserDefaults.lastUsedKey
                    
                    // Then
                    expect(iosKey).toNot(equal(macKey))
                }
                
                it("should apply platform-specific limits") {
                    // Given - Create a long history
                    var longHistory: [String] = []
                    for i in 1...20 {
                        longHistory.append("user\(i)")
                    }
                    mockUserDefaults.mockStringArray = longHistory
                    
                    // When - Test with different platforms
                    manageSearchHistoryUseCase.addToSearchHistory(username: "iosuser", platform: .iOS)
                    let iosCount = mockUserDefaults.storedStringArray?.count
                    
                    mockUserDefaults.mockStringArray = longHistory
                    manageSearchHistoryUseCase.addToSearchHistory(username: "ipaduser", platform: .iPadOS)
                    let ipadCount = mockUserDefaults.storedStringArray?.count
                    
                    mockUserDefaults.mockStringArray = longHistory
                    manageSearchHistoryUseCase.addToSearchHistory(username: "tvuser", platform: .tvOS)
                    let tvCount = mockUserDefaults.storedStringArray?.count
                    
                    // Then
                    expect(iosCount).to(equal(10)) // iOS max is 10
                    expect(ipadCount).to(equal(15)) // iPadOS max is 15
                    expect(tvCount).to(equal(5)) // tvOS max is 5
                }
            }
        }
    }
}

class HistoryMockUserDefaults: UserDefaults {
    var mockStringArray: [String]?
    var storedStringArray: [String]?
    var lastUsedKey: String?
    var removedKey: String?
    var wasSetCalled = false
    
    override func stringArray(forKey defaultName: String) -> [String]? {
        lastUsedKey = defaultName
        return mockStringArray
    }
    
    override func set(_ value: Any?, forKey defaultName: String) {
        lastUsedKey = defaultName
        wasSetCalled = true
        if let stringArray = value as? [String] {
            storedStringArray = stringArray
        }
    }
    
    override func removeObject(forKey defaultName: String) {
        lastUsedKey = defaultName
        removedKey = defaultName
    }
} 