import Quick
import Nimble
import Foundation
@testable import GH_Profile_Explorer

class RepositoryMapperTests: QuickSpec {
    override class func spec() {
        describe("RepositoryMapper") {
            context("mapToDomain with RepositoryResponseDTO") {
                it("should map DTO to domain model correctly") {
                    // Given
                    let createdAt = Date()
                    let updatedAt = Date()
                    let dto = RepositoryResponseDTO(
                        id: 1,
                        name: "test-repo",
                        fullName: "testuser/test-repo",
                        owner: OwnerResponseDTO(
                            id: 2,
                            login: "testuser",
                            avatarUrl: "https://example.com/avatar.png",
                            url: "https://api.github.com/users/testuser",
                            htmlUrl: "https://github.com/testuser"
                        ),
                        isPrivate: false,
                        htmlUrl: "https://github.com/testuser/test-repo",
                        description: "Test repository",
                        fork: false,
                        language: "Swift",
                        forksCount: 5,
                        stargazersCount: 10,
                        watchersCount: 3,
                        defaultBranch: "main",
                        createdAt: createdAt,
                        updatedAt: updatedAt,
                        topics: ["swift", "ios"]
                    )
                    
                    // When
                    let result = try? RepositoryMapper.mapToDomain(response: dto)
                    
                    // Then
                    expect(result).toNot(beNil())
                    expect(result?.id).to(equal(1))
                    expect(result?.name).to(equal("test-repo"))
                    expect(result?.fullName).to(equal("testuser/test-repo"))
                    expect(result?.owner.id).to(equal(2))
                    expect(result?.owner.login).to(equal("testuser"))
                    expect(result?.isPrivate).to(equal(false))
                    expect(result?.htmlURL.absoluteString).to(equal("https://github.com/testuser/test-repo"))
                    expect(result?.description).to(equal("Test repository"))
                    expect(result?.fork).to(equal(false))
                    expect(result?.language).to(equal("Swift"))
                    expect(result?.forksCount).to(equal(5))
                    expect(result?.stargazersCount).to(equal(10))
                    expect(result?.watchersCount).to(equal(3))
                    expect(result?.defaultBranch).to(equal("main"))
                    expect(result?.createdAt).to(equal(createdAt))
                    expect(result?.updatedAt).to(equal(updatedAt))
                    expect(result?.topics).to(equal(["swift", "ios"]))
                }
                
                it("should handle nil topics") {
                    // Given
                    let createdAt = Date()
                    let updatedAt = Date()
                    let dto = RepositoryResponseDTO(
                        id: 1,
                        name: "test-repo",
                        fullName: "testuser/test-repo",
                        owner: OwnerResponseDTO(
                            id: 2,
                            login: "testuser",
                            avatarUrl: "https://example.com/avatar.png",
                            url: "https://api.github.com/users/testuser",
                            htmlUrl: "https://github.com/testuser"
                        ),
                        isPrivate: false,
                        htmlUrl: "https://github.com/testuser/test-repo",
                        description: "Test repository",
                        fork: false,
                        language: "Swift",
                        forksCount: 5,
                        stargazersCount: 10,
                        watchersCount: 3,
                        defaultBranch: "main",
                        createdAt: createdAt,
                        updatedAt: updatedAt,
                        topics: nil
                    )
                    
                    // When
                    let result = try? RepositoryMapper.mapToDomain(response: dto)
                    
                    // Then
                    expect(result).toNot(beNil())
                    expect(result?.topics).to(equal([]))
                }
                
                it("should throw error for invalid HTML URL") {
                    // Given
                    let dto = RepositoryResponseDTO(
                        id: 1,
                        name: "test-repo",
                        fullName: "testuser/test-repo",
                        owner: OwnerResponseDTO(
                            id: 2,
                            login: "testuser",
                            avatarUrl: "https://example.com/avatar.png",
                            url: "https://api.github.com/users/testuser",
                            htmlUrl: "https://github.com/testuser"
                        ),
                        isPrivate: false,
                        htmlUrl: "invalid url",
                        description: "Test repository",
                        fork: false,
                        language: "Swift",
                        forksCount: 5,
                        stargazersCount: 10,
                        watchersCount: 3,
                        defaultBranch: "main",
                        createdAt: Date(),
                        updatedAt: Date(),
                        topics: ["swift", "ios"]
                    )
                    
                    // When & Then
                    expect { try RepositoryMapper.mapToDomain(response: dto) }.to(throwError(AppError.decodingError))
                }
            }
            
            context("mapToDomain with array of RepositoryResponseDTO") {
                it("should map DTOs to domain models correctly") {
                    // Given
                    let dtos = [
                        RepositoryResponseDTO(
                            id: 1,
                            name: "repo1",
                            fullName: "user/repo1",
                            owner: OwnerResponseDTO(
                                id: 2,
                                login: "user",
                                avatarUrl: "https://example.com/avatar.png",
                                url: "https://api.github.com/users/user",
                                htmlUrl: "https://github.com/user"
                            ),
                            isPrivate: false,
                            htmlUrl: "https://github.com/user/repo1",
                            description: "Repository 1",
                            fork: false,
                            language: "Swift",
                            forksCount: 3,
                            stargazersCount: 8,
                            watchersCount: 2,
                            defaultBranch: "main",
                            createdAt: Date(),
                            updatedAt: Date(),
                            topics: ["swift"]
                        ),
                        RepositoryResponseDTO(
                            id: 2,
                            name: "repo2",
                            fullName: "user/repo2",
                            owner: OwnerResponseDTO(
                                id: 2,
                                login: "user",
                                avatarUrl: "https://example.com/avatar.png",
                                url: "https://api.github.com/users/user",
                                htmlUrl: "https://github.com/user"
                            ),
                            isPrivate: true,
                            htmlUrl: "https://github.com/user/repo2",
                            description: "Repository 2",
                            fork: true,
                            language: "Swift",
                            forksCount: 1,
                            stargazersCount: 4,
                            watchersCount: 1,
                            defaultBranch: "master",
                            createdAt: Date(),
                            updatedAt: Date(),
                            topics: ["ios"]
                        )
                    ]
                    
                    // When
                    let result = try? RepositoryMapper.mapToDomain(responses: dtos)
                    
                    // Then
                    expect(result).toNot(beNil())
                    expect(result?.count).to(equal(2))
                    expect(result?[0].name).to(equal("repo1"))
                    expect(result?[1].name).to(equal("repo2"))
                }
            }
        }
    }
} 