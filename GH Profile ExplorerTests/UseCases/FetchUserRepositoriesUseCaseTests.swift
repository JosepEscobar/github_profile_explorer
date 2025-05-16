import Quick
import Nimble
import Foundation
@testable import GH_Profile_Explorer

class FetchUserRepositoriesUseCaseTests: QuickSpec {
    override class func spec() {
        var fetchUserRepositoriesUseCase: FetchUserRepositoriesUseCase!
        var mockUserRepository: FetchReposMockUserRepository!
        
        beforeEach {
            mockUserRepository = FetchReposMockUserRepository()
            fetchUserRepositoriesUseCase = FetchUserRepositoriesUseCase(repository: mockUserRepository)
        }
        
        describe("FetchUserRepositoriesUseCase") {
            context("when executing with a valid username") {
                it("should return the correct repositories") {
                    // Given
                    let expectedRepositories = [
                        Repository(
                            id: 1,
                            name: "Repo1",
                            fullName: "testuser/Repo1",
                            owner: User(
                                id: 1,
                                login: "testuser",
                                name: nil,
                                avatarURL: URL(string: "https://example.com/avatar.png")!,
                                bio: nil,
                                followers: 0,
                                following: 0,
                                location: nil,
                                publicRepos: 0,
                                publicGists: 0
                            ),
                            isPrivate: false,
                            htmlURL: URL(string: "https://github.com/testuser/Repo1")!,
                            description: "Description",
                            fork: false,
                            language: "Swift",
                            forksCount: 0,
                            stargazersCount: 0,
                            watchersCount: 0,
                            defaultBranch: "main",
                            createdAt: Date(),
                            updatedAt: Date(),
                            topics: []
                        )
                    ]
                    mockUserRepository.mockRepositories = expectedRepositories
                    
                    // When
                    waitUntil { done in
                        Task {
                            let repositories = try await fetchUserRepositoriesUseCase.execute(username: "testuser")
                            
                            // Then
                            expect(repositories).to(equal(expectedRepositories))
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
                                _ = try await fetchUserRepositoriesUseCase.execute(username: "")
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
                                _ = try await fetchUserRepositoriesUseCase.execute(username: "test user")
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

class FetchReposMockUserRepository: UserRepositoryProtocol {
    var mockUser: User?
    var mockRepositories: [Repository] = []
    var mockUsers: [User] = []
    
    func fetchUser(username: String) async throws -> User {
        if let user = mockUser {
            return user
        }
        throw AppError.unexpectedError("User not found")
    }
    
    func fetchUserRepositories(username: String) async throws -> [Repository] {
        return mockRepositories
    }
    
    func searchUsers(query: String) async throws -> [User] {
        return mockUsers
    }
} 