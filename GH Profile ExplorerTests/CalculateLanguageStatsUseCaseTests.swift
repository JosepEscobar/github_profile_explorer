import Quick
import Nimble
import Foundation
@testable import GH_Profile_Explorer

class CalculateLanguageStatsUseCaseTests: QuickSpec {
    override class func spec() {
        var calculateLanguageStatsUseCase: CalculateLanguageStatsUseCase!
        
        beforeEach {
            calculateLanguageStatsUseCase = CalculateLanguageStatsUseCase()
        }
        
        describe("CalculateLanguageStatsUseCase") {
            context("when executing with repositories having languages") {
                it("should calculate language stats correctly") {
                    // Given
                    let repositories = [
                        createRepository(id: 1, language: "Swift"),
                        createRepository(id: 2, language: "Swift"),
                        createRepository(id: 3, language: "JavaScript"),
                        createRepository(id: 4, language: "Python"),
                        createRepository(id: 5, language: "Swift"),
                        createRepository(id: 6, language: "JavaScript"),
                        createRepository(id: 7, language: nil)
                    ]
                    
                    // When
                    let result = calculateLanguageStatsUseCase.execute(for: repositories)
                    
                    // Then
                    // The result should be sorted by count in descending order
                    expect(result.count).to(equal(3))
                    expect(result[0].language).to(equal("Swift"))
                    expect(result[0].count).to(equal(3))
                    expect(result[1].language).to(equal("JavaScript"))
                    expect(result[1].count).to(equal(2))
                    expect(result[2].language).to(equal("Python"))
                    expect(result[2].count).to(equal(1))
                }
            }
            
            context("when executing with repositories without languages") {
                it("should return an empty array") {
                    // Given
                    let repositories = [
                        createRepository(id: 1, language: nil),
                        createRepository(id: 2, language: nil),
                        createRepository(id: 3, language: nil)
                    ]
                    
                    // When
                    let result = calculateLanguageStatsUseCase.execute(for: repositories)
                    
                    // Then
                    expect(result).to(beEmpty())
                }
            }
            
            context("when executing with an empty repository list") {
                it("should return an empty array") {
                    // Given
                    let repositories: [Repository] = []
                    
                    // When
                    let result = calculateLanguageStatsUseCase.execute(for: repositories)
                    
                    // Then
                    expect(result).to(beEmpty())
                }
            }
        }
    }
    
    private static func createRepository(id: Int, language: String?) -> Repository {
        return Repository(
            id: id,
            name: "Repo\(id)",
            fullName: "user/Repo\(id)",
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
            htmlURL: URL(string: "https://github.com/user/Repo\(id)")!,
            description: "Repository \(id)",
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