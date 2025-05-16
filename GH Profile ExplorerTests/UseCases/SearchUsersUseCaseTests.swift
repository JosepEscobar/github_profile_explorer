import Quick
import Nimble
import Foundation
@testable import GH_Profile_Explorer

class SearchUsersUseCaseTests: QuickSpec {
    override class func spec() {
        var searchUsersUseCase: SearchUsersUseCase!
        var mockUserRepository: SearchUsersMockRepository!
        
        beforeEach {
            mockUserRepository = SearchUsersMockRepository()
            searchUsersUseCase = SearchUsersUseCase(repository: mockUserRepository)
        }
        
        describe("SearchUsersUseCase") {
            context("when executing with a valid query") {
                it("should return the correct users") {
                    // Given
                    let expectedUsers = [User(id: 1, login: "testuser", name: "Test User", avatarURL: URL(string: "https://example.com/avatar.png")!, bio: "Bio", followers: 10, following: 5, location: "Location", publicRepos: 2, publicGists: 1)]
                    mockUserRepository.mockUsers = expectedUsers
                    
                    // When
                    waitUntil { done in
                        Task {
                            let users = try await searchUsersUseCase.execute(query: "test")
                            
                            // Then
                            expect(users).to(equal(expectedUsers))
                            done()
                        }
                    }
                }
            }
            
            context("when executing with an empty query") {
                it("should throw an error") {
                    // When
                    waitUntil { done in
                        Task {
                            do {
                                _ = try await searchUsersUseCase.execute(query: "")
                                fail("Expected to throw an error")
                            } catch {
                                // Then
                                expect(error).to(matchError(AppError.unexpectedError("Search query cannot be empty")))
                                done()
                            }
                        }
                    }
                }
            }
        }
    }
}

class SearchUsersMockRepository: UserRepositoryProtocol {
    var mockUsers: [User] = []
    
    func fetchUser(username: String) async throws -> User {
        throw AppError.unexpectedError("User not found")
    }
    
    func fetchUserRepositories(username: String) async throws -> [Repository] {
        return []
    }
    
    func searchUsers(query: String) async throws -> [User] {
        return mockUsers
    }
} 