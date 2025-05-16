import Quick
import Nimble
import Foundation
@testable import GH_Profile_Explorer

class FetchUserUseCaseTests: QuickSpec {
    override class func spec() {
        var fetchUserUseCase: FetchUserUseCase!
        var mockUserRepository: FetchUserMockUserRepository!
        
        beforeEach {
            mockUserRepository = FetchUserMockUserRepository()
            fetchUserUseCase = FetchUserUseCase(repository: mockUserRepository)
        }
        
        describe("FetchUserUseCase") {
            context("when executing with a valid username") {
                it("should return the correct user") {
                    // Given
                    let expectedUser = User(id: 1, login: "testuser", name: "Test User", avatarURL: URL(string: "https://example.com/avatar.png")!, bio: "Bio", followers: 10, following: 5, location: "Location", publicRepos: 2, publicGists: 1)
                    mockUserRepository.mockUser = expectedUser
                    
                    // When
                    waitUntil { done in
                        Task {
                            let user = try await fetchUserUseCase.execute(username: "testuser")
                            
                            // Then
                            expect(user).to(equal(expectedUser))
                            done()
                        }
                    }
                }
            }
            
            context("when executing with an empty username") {
                it("should throw an error") {
                    // When
                    waitUntil { done in
                        Task {
                            do {
                                _ = try await fetchUserUseCase.execute(username: "")
                                fail("Expected to throw an error")
                            } catch {
                                // Then
                                expect(error).to(matchError(AppError.unexpectedError("Username cannot be empty")))
                                done()
                            }
                        }
                    }
                }
            }
            
            context("when executing with a username containing spaces") {
                it("should throw an error") {
                    // When
                    waitUntil { done in
                        Task {
                            do {
                                _ = try await fetchUserUseCase.execute(username: "test user")
                                fail("Expected to throw an error")
                            } catch {
                                // Then
                                expect(error).to(matchError(AppError.unexpectedError("Username cannot contain spaces")))
                                done()
                            }
                        }
                    }
                }
            }
        }
    }
}

class FetchUserMockUserRepository: UserRepositoryProtocol {
    var mockUser: User?
    
    func fetchUser(username: String) async throws -> User {
        if let user = mockUser {
            return user
        }
        throw AppError.unexpectedError("User not found")
    }
    
    func fetchUserRepositories(username: String) async throws -> [Repository] {
        return []
    }
    
    func searchUsers(query: String) async throws -> [User] {
        return []
    }
}