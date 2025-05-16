import Quick
import Nimble
import Foundation
@testable import GH_Profile_Explorer

class UserRepositoryTests: QuickSpec {
    override class func spec() {
        var userRepository: UserRepository!
        var mockNetworkClient: MockNetworkClient!
        
        beforeEach {
            mockNetworkClient = MockNetworkClient()
            userRepository = UserRepository(networkClient: mockNetworkClient)
        }
        
        describe("UserRepository") {
            context("when fetching a user") {
                it("should return the correct user") {
                    // Given
                    let expectedUser = User(id: 1, login: "testuser", name: "Test User", avatarURL: URL(string: "https://example.com/avatar.png")!, bio: "Bio", followers: 10, following: 5, location: "Location", publicRepos: 2, publicGists: 1)
                    mockNetworkClient.mockResponse = UserResponseDTO(id: 1, login: "testuser", name: "Test User", avatarUrl: "https://example.com/avatar.png", bio: "Bio", followers: 10, following: 5, location: "Location", publicRepos: 2, publicGists: 1)
                    
                    // When
                    waitUntil { done in
                        Task {
                            let user = try await userRepository.fetchUser(username: "testuser")
                            
                            // Then
                            expect(user).to(equal(expectedUser))
                            done()
                        }
                    }
                }
            }
            
            context("when fetching user repositories") {
                it("should return the correct repositories") {
                    // Given
                    let expectedRepositories = [Repository(id: 1, name: "Repo1", fullName: "testuser/Repo1", owner: User(id: 1, login: "testuser", name: nil, avatarURL: URL(string: "https://example.com/avatar.png")!, bio: nil, followers: 0, following: 0, location: nil, publicRepos: 0, publicGists: 0), isPrivate: false, htmlURL: URL(string: "https://example.com/repo1")!, description: "Description", fork: false, language: "Swift", forksCount: 0, stargazersCount: 0, watchersCount: 0, defaultBranch: "main", createdAt: Date(), updatedAt: Date(), topics: [])]
                    mockNetworkClient.mockResponse = [RepositoryResponseDTO(id: 1, name: "Repo1", fullName: "testuser/Repo1", owner: OwnerResponseDTO(id: 1, login: "testuser", avatarUrl: "https://example.com/avatar.png", url: "https://example.com", htmlUrl: "https://example.com/repo1"), isPrivate: false, htmlUrl: "https://example.com/repo1", description: "Description", fork: false, language: "Swift", forksCount: 0, stargazersCount: 0, watchersCount: 0, defaultBranch: "main", createdAt: Date(), updatedAt: Date(), topics: [])]
                    
                    // When
                    waitUntil { done in
                        Task {
                            let repositories = try await userRepository.fetchUserRepositories(username: "testuser")
                            
                            // Then
                            expect(repositories).to(equal(expectedRepositories))
                            done()
                        }
                    }
                }
            }
            
            context("when searching users") {
                it("should return the correct users") {
                    // Given
                    let expectedUsers = [User(id: 1, login: "testuser", name: "Test User", avatarURL: URL(string: "https://example.com/avatar.png")!, bio: "Bio", followers: 10, following: 5, location: "Location", publicRepos: 2, publicGists: 1)]
                    mockNetworkClient.mockResponse = UserSearchResponseDTO(items: [UserResponseDTO(id: 1, login: "testuser", name: "Test User", avatarUrl: "https://example.com/avatar.png", bio: "Bio", followers: 10, following: 5, location: "Location", publicRepos: 2, publicGists: 1)], totalCount: 1)
                    
                    // When
                    waitUntil { done in
                        Task {
                            let users = try await userRepository.searchUsers(query: "test")
                            
                            // Then
                            expect(users).to(equal(expectedUsers))
                            done()
                        }
                    }
                }
            }
        }
    }
}

class MockNetworkClient: NetworkClientProtocol {
    var mockResponse: Any?
    
    func fetch<T>(endpoint: Endpoint) async throws -> T where T : Decodable {
        if let response = mockResponse as? T {
            return response
        }
        throw NSError(domain: "MockNetworkClient", code: 1, userInfo: nil)
    }
} 