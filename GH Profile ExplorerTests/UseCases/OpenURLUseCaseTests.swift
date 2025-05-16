import Quick
import Nimble
import Foundation
@testable import GH_Profile_Explorer

class OpenURLUseCaseTests: QuickSpec {
    override class func spec() {
        var openURLUseCase: OpenURLUseCase!
        
        beforeEach {
            openURLUseCase = OpenURLUseCase()
        }
        
        describe("OpenURLUseCase") {
            context("when creating GitHub profile URL") {
                it("should create a valid URL for a username") {
                    // When
                    let url = openURLUseCase.createGitHubProfileURL(for: "octocat")
                    
                    // Then
                    expect(url).toNot(beNil())
                    expect(url?.absoluteString).to(equal("https://github.com/octocat"))
                }
                
                it("should handle usernames with special characters") {
                    // When
                    let url = openURLUseCase.createGitHubProfileURL(for: "test-user")
                    
                    // Then
                    expect(url).toNot(beNil())
                    expect(url?.absoluteString).to(equal("https://github.com/test-user"))
                }
            }
            
            context("when creating repository URL") {
                it("should return the repository's HTML URL") {
                    // Given
                    let repository = Repository(
                        id: 1,
                        name: "test-repo",
                        fullName: "user/test-repo",
                        owner: User(
                            id: 1,
                            login: "user",
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
                        htmlURL: URL(string: "https://github.com/user/test-repo")!,
                        description: "Test repository",
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
                    
                    // When
                    let url = openURLUseCase.createRepositoryURL(for: repository)
                    
                    // Then
                    expect(url.absoluteString).to(equal("https://github.com/user/test-repo"))
                }
            }
        }
    }
} 