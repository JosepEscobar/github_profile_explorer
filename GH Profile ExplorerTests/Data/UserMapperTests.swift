import Quick
import Nimble
import Foundation
@testable import GH_Profile_Explorer

class UserMapperTests: QuickSpec {
    override class func spec() {
        describe("UserMapper") {
            context("mapToDomain with UserResponseDTO") {
                it("should map DTO to domain model correctly") {
                    // Given
                    let dto = UserResponseDTO(
                        id: 1,
                        login: "testuser",
                        name: "Test User",
                        avatarUrl: "https://example.com/avatar.png",
                        bio: "Test bio",
                        followers: 10,
                        following: 5,
                        location: "Test Location",
                        publicRepos: 20,
                        publicGists: 3
                    )
                    
                    // When
                    let result = try? UserMapper.mapToDomain(response: dto)
                    
                    // Then
                    expect(result).toNot(beNil())
                    expect(result?.id).to(equal(1))
                    expect(result?.login).to(equal("testuser"))
                    expect(result?.name).to(equal("Test User"))
                    expect(result?.avatarURL.absoluteString).to(equal("https://example.com/avatar.png"))
                    expect(result?.bio).to(equal("Test bio"))
                    expect(result?.followers).to(equal(10))
                    expect(result?.following).to(equal(5))
                    expect(result?.location).to(equal("Test Location"))
                    expect(result?.publicRepos).to(equal(20))
                    expect(result?.publicGists).to(equal(3))
                }
                
                it("should throw error for invalid avatar URL") {
                    // Given
                    let dto = UserResponseDTO(
                        id: 1,
                        login: "testuser",
                        name: "Test User",
                        avatarUrl: "invalid url",
                        bio: "Test bio",
                        followers: 10,
                        following: 5,
                        location: "Test Location",
                        publicRepos: 20,
                        publicGists: 3
                    )
                    
                    // When & Then
                    expect { try UserMapper.mapToDomain(response: dto) }.to(throwError(AppError.decodingError))
                }
            }
            
            context("mapOwnerToDomain with OwnerResponseDTO") {
                it("should map DTO to domain model correctly") {
                    // Given
                    let dto = OwnerResponseDTO(
                        id: 2,
                        login: "owneruser",
                        avatarUrl: "https://example.com/owner.png",
                        url: "https://api.github.com/users/owneruser",
                        htmlUrl: "https://github.com/owneruser"
                    )
                    
                    // When
                    let result = try? UserMapper.mapOwnerToDomain(response: dto)
                    
                    // Then
                    expect(result).toNot(beNil())
                    expect(result?.id).to(equal(2))
                    expect(result?.login).to(equal("owneruser"))
                    expect(result?.name).to(beNil())
                    expect(result?.avatarURL.absoluteString).to(equal("https://example.com/owner.png"))
                    expect(result?.bio).to(beNil())
                    expect(result?.followers).to(equal(0))
                    expect(result?.following).to(equal(0))
                    expect(result?.location).to(beNil())
                    expect(result?.publicRepos).to(equal(0))
                    expect(result?.publicGists).to(equal(0))
                }
                
                it("should throw error for invalid avatar URL") {
                    // Given
                    let dto = OwnerResponseDTO(
                        id: 2,
                        login: "owneruser",
                        avatarUrl: "invalid url",
                        url: "https://api.github.com/users/owneruser",
                        htmlUrl: "https://github.com/owneruser"
                    )
                    
                    // When & Then
                    expect { try UserMapper.mapOwnerToDomain(response: dto) }.to(throwError(AppError.decodingError))
                }
            }
            
            context("mapToDomain with array of UserResponseDTO") {
                it("should map DTOs to domain models correctly") {
                    // Given
                    let dtos = [
                        UserResponseDTO(
                            id: 1,
                            login: "user1",
                            name: "User One",
                            avatarUrl: "https://example.com/avatar1.png",
                            bio: "Bio 1",
                            followers: 10,
                            following: 5,
                            location: "Location 1",
                            publicRepos: 20,
                            publicGists: 3
                        ),
                        UserResponseDTO(
                            id: 2,
                            login: "user2",
                            name: "User Two",
                            avatarUrl: "https://example.com/avatar2.png",
                            bio: "Bio 2",
                            followers: 20,
                            following: 15,
                            location: "Location 2",
                            publicRepos: 30,
                            publicGists: 5
                        )
                    ]
                    
                    // When
                    let result = try? UserMapper.mapToDomain(responses: dtos)
                    
                    // Then
                    expect(result).toNot(beNil())
                    expect(result?.count).to(equal(2))
                    expect(result?[0].login).to(equal("user1"))
                    expect(result?[1].login).to(equal("user2"))
                }
            }
            
            context("mapSearchResponseToDomain with UserSearchResponseDTO") {
                it("should map search response to domain models correctly") {
                    // Given
                    let dto = UserSearchResponseDTO(
                        items: [
                            UserResponseDTO(
                                id: 1,
                                login: "user1",
                                name: "User One",
                                avatarUrl: "https://example.com/avatar1.png",
                                bio: "Bio 1",
                                followers: 10,
                                following: 5,
                                location: "Location 1",
                                publicRepos: 20,
                                publicGists: 3
                            )
                        ],
                        totalCount: 1
                    )
                    
                    // When
                    let result = try? UserMapper.mapSearchResponseToDomain(response: dto)
                    
                    // Then
                    expect(result).toNot(beNil())
                    expect(result?.count).to(equal(1))
                    expect(result?[0].login).to(equal("user1"))
                }
            }
        }
    }
} 