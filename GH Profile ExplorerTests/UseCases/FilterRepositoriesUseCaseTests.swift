import Quick
import Nimble
import Foundation
@testable import GH_Profile_Explorer

class FilterRepositoriesUseCaseTests: QuickSpec {
    override class func spec() {
        var filterRepositoriesUseCase: FilterRepositoriesUseCase!
        var repositories: [Repository]!
        
        beforeEach {
            filterRepositoriesUseCase = FilterRepositoriesUseCase()
            
            repositories = [
                createRepository(id: 1, name: "swift-repo", description: "A Swift repository", language: "Swift"),
                createRepository(id: 2, name: "python-code", description: "Python code examples", language: "Python"),
                createRepository(id: 3, name: "javascript-utils", description: "JavaScript utilities", language: "JavaScript"),
                createRepository(id: 4, name: "ios-app", description: "An iOS app written in Swift", language: "Swift"),
                createRepository(id: 5, name: "react-components", description: "React components library", language: "JavaScript"),
                createRepository(id: 6, name: "empty-repo", description: nil, language: nil)
            ]
        }
        
        describe("FilterRepositoriesUseCase") {
            context("when filtering by search text") {
                it("should filter repositories that contain the search text in name") {
                    // When
                    let result = filterRepositoriesUseCase.filterBySearchText(repositories: repositories, searchText: "swift")
                    
                    // Then
                    expect(result.count).to(equal(2))
                    expect(result.map { $0.id }).to(contain(1, 4))
                }
                
                it("should filter repositories that contain the search text in description") {
                    // When
                    let result = filterRepositoriesUseCase.filterBySearchText(repositories: repositories, searchText: "utilities")
                    
                    // Then
                    expect(result.count).to(equal(1))
                    expect(result.first?.id).to(equal(3))
                }
                
                it("should filter repositories that contain the search text in language") {
                    // When
                    let result = filterRepositoriesUseCase.filterBySearchText(repositories: repositories, searchText: "python")
                    
                    // Then
                    expect(result.count).to(equal(1))
                    expect(result.first?.id).to(equal(2))
                }
                
                it("should return all repositories for empty search text") {
                    // When
                    let result = filterRepositoriesUseCase.filterBySearchText(repositories: repositories, searchText: "")
                    
                    // Then
                    expect(result.count).to(equal(repositories.count))
                }
                
                it("should be case insensitive") {
                    // When
                    let result = filterRepositoriesUseCase.filterBySearchText(repositories: repositories, searchText: "SWIFT")
                    
                    // Then
                    expect(result.count).to(equal(2))
                    expect(result.map { $0.id }).to(contain(1, 4))
                }
            }
            
            context("when filtering by language") {
                it("should filter repositories by language") {
                    // When
                    let result = filterRepositoriesUseCase.filterByLanguage(repositories: repositories, language: "Swift")
                    
                    // Then
                    expect(result.count).to(equal(2))
                    expect(result.map { $0.id }).to(contain(1, 4))
                }
                
                it("should return all repositories for nil language") {
                    // When
                    let result = filterRepositoriesUseCase.filterByLanguage(repositories: repositories, language: nil)
                    
                    // Then
                    expect(result.count).to(equal(repositories.count))
                }
            }
            
            context("when filtering by both search text and language") {
                it("should apply both filters") {
                    // When
                    let result = filterRepositoriesUseCase.filterBySearchTextAndLanguage(
                        repositories: repositories,
                        searchText: "app",
                        language: "Swift"
                    )
                    
                    // Then
                    expect(result.count).to(equal(1))
                    expect(result.first?.id).to(equal(4))
                }
                
                it("should handle empty search text and nil language") {
                    // When
                    let result = filterRepositoriesUseCase.filterBySearchTextAndLanguage(
                        repositories: repositories,
                        searchText: "",
                        language: nil
                    )
                    
                    // Then
                    expect(result.count).to(equal(repositories.count))
                }
            }
            
            context("when extracting unique languages") {
                it("should return unique languages in alphabetical order") {
                    // When
                    let result = filterRepositoriesUseCase.extractUniqueLanguages(from: repositories)
                    
                    // Then
                    expect(result.count).to(equal(3))
                    expect(result).to(equal(["JavaScript", "Python", "Swift"]))
                }
                
                it("should ignore nil languages") {
                    // When
                    let result = filterRepositoriesUseCase.extractUniqueLanguages(from: [
                        createRepository(id: 1, name: "repo1", description: "Repo 1", language: "Swift"),
                        createRepository(id: 2, name: "repo2", description: "Repo 2", language: nil),
                        createRepository(id: 3, name: "repo3", description: "Repo 3", language: "Swift")
                    ])
                    
                    // Then
                    expect(result.count).to(equal(1))
                    expect(result).to(equal(["Swift"]))
                }
                
                it("should return an empty array for repositories without languages") {
                    // When
                    let result = filterRepositoriesUseCase.extractUniqueLanguages(from: [
                        createRepository(id: 1, name: "repo1", description: "Repo 1", language: nil),
                        createRepository(id: 2, name: "repo2", description: "Repo 2", language: nil)
                    ])
                    
                    // Then
                    expect(result).to(beEmpty())
                }
            }
        }
    }
    
    private static func createRepository(id: Int, name: String, description: String?, language: String?) -> Repository {
        return Repository(
            id: id,
            name: name,
            fullName: "user/\(name)",
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
            htmlURL: URL(string: "https://github.com/user/\(name)")!,
            description: description,
            fork: false,
            language: language,
            forksCount: 0,
            stargazersCount: 0,
            watchersCount: 0,
            defaultBranch: "main",
            createdAt: Date(),
            updatedAt: Date(),
            topics: []
        )
    }
} 