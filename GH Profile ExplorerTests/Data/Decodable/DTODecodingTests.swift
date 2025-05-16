import Quick
import Nimble
import Foundation
@testable import GH_Profile_Explorer

class DTODecodingTests: QuickSpec {
    override class func spec() {
        let decoder: JSONDecoder = {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            // Configure date decoding strategy for repositories
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            return decoder
        }()
        
        // MARK: - Helper Methods
        
        func loadJSON(from fileName: String) -> Data {
            let testBundle = Bundle(for: DTODecodingTests.self)
            
            // 1. First look directly in the bundle
            if let fileURL = testBundle.url(forResource: fileName, withExtension: "json") {
                do {
                    let data = try Data(contentsOf: fileURL)
                    return data
                } catch {
                    // Continue trying with other methods
                }
            }
            
            // 2. Look in the resource directory of the bundle
            let resourcePath = testBundle.resourcePath ?? ""
            let fileManager = FileManager.default
            var allPaths: [String] = []
            
            if let enumerator = fileManager.enumerator(atPath: resourcePath) {
                while let path = enumerator.nextObject() as? String {
                    if path.hasSuffix("\(fileName).json") {
                        allPaths.append(path)
                    }
                }
            }
            
            if let firstMatchingPath = allPaths.first {
                let fullPath = URL(fileURLWithPath: resourcePath).appendingPathComponent(firstMatchingPath).path
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: fullPath))
                    return data
                } catch {
                    // Continue trying with other methods
                }
            }
            
            // 3. Look in the TestData directory
            let testDataPath = "\(resourcePath)/TestData/\(fileName).json"
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: testDataPath))
                return data
            } catch {
                // Continue trying with other methods
            }
            
            // 4. Last resort: load from an absolute path for development testing
            let devPath = "/Users/josepescobar/Developer/iOS/GH Profile Explorer/GH Profile ExplorerTests/Data/TestData/\(fileName).json"
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: devPath))
                return data
            } catch {
                // 5. Create a detailed error message to help diagnose the problem
                let errorMessage = """
                Failed to load JSON file \(fileName).json from any of these locations:
                - Bundle direct: \(testBundle.url(forResource: fileName, withExtension: "json") ?? URL(fileURLWithPath: "not found"))
                - Resource path: \(resourcePath)/\(fileName).json
                - TestData path: \(testDataPath)
                - Absolute path: \(devPath)
                """
                
                fail(errorMessage)
                return Data()
            }
        }
        
        describe("DTOs Decodable") {
            // MARK: - UserResponseDTO Tests
            
            context("UserResponseDTO") {
                it("should decode correctly from valid JSON") {
                    // Given
                    let jsonData = loadJSON(from: "user_response")
                    
                    // When
                    let userDTO = try? decoder.decode(UserResponseDTO.self, from: jsonData)
                    
                    // Then
                    expect(userDTO).toNot(beNil())
                    expect(userDTO?.id).to(equal(12345))
                    expect(userDTO?.login).to(equal("testuser"))
                    expect(userDTO?.name).to(equal("Test User"))
                    expect(userDTO?.avatarUrl).to(equal("https://github.com/avatars/testuser.png"))
                    expect(userDTO?.bio).to(equal("Software developer and open source enthusiast"))
                    expect(userDTO?.followers).to(equal(100))
                    expect(userDTO?.following).to(equal(50))
                    expect(userDTO?.location).to(equal("San Francisco, CA"))
                    expect(userDTO?.publicRepos).to(equal(25))
                    expect(userDTO?.publicGists).to(equal(10))
                }
                
                it("should handle missing optional fields") {
                    // Given: A JSON with missing optional fields
                    let jsonData = loadJSON(from: "user_response_missing_fields")
                    
                    // When
                    let userDTO = try? decoder.decode(UserResponseDTO.self, from: jsonData)
                    
                    // Then: Optional fields should be nil
                    expect(userDTO).toNot(beNil())
                    expect(userDTO?.id).to(equal(12345))
                    expect(userDTO?.login).to(equal("testuser"))
                    expect(userDTO?.name).to(beNil())
                    expect(userDTO?.avatarUrl).to(equal("https://github.com/avatars/testuser.png"))
                    expect(userDTO?.bio).to(beNil())
                    expect(userDTO?.location).to(beNil())
                }
                
                it("should fail when decoding invalid JSON") {
                    // Given: An invalid JSON for UserResponseDTO
                    let jsonData = loadJSON(from: "user_response_invalid")
                    
                    // When & Then: Should throw a decoding error
                    expect {
                        try decoder.decode(UserResponseDTO.self, from: jsonData)
                    }.to(throwError { error in
                        expect(error).to(beAKindOf(DecodingError.self))
                    })
                }
            }
            
            // MARK: - OwnerResponseDTO Tests
            
            context("OwnerResponseDTO") {
                it("should decode correctly from valid JSON") {
                    // Given
                    let jsonData = loadJSON(from: "owner_response")
                    
                    // When
                    let ownerDTO = try? decoder.decode(OwnerResponseDTO.self, from: jsonData)
                    
                    // Then
                    expect(ownerDTO).toNot(beNil())
                    expect(ownerDTO?.id).to(equal(12345))
                    expect(ownerDTO?.login).to(equal("testuser"))
                    expect(ownerDTO?.avatarUrl).to(equal("https://github.com/avatars/testuser.png"))
                    expect(ownerDTO?.url).to(equal("https://api.github.com/users/testuser"))
                    expect(ownerDTO?.htmlUrl).to(equal("https://github.com/testuser"))
                }
            }
            
            // MARK: - RepositoryResponseDTO Tests
            
            context("RepositoryResponseDTO") {
                it("should decode correctly from valid JSON") {
                    // Given
                    let jsonData = loadJSON(from: "repository_response")
                    
                    // When
                    let repoDTO = try? decoder.decode(RepositoryResponseDTO.self, from: jsonData)
                    
                    // Then
                    expect(repoDTO).toNot(beNil())
                    expect(repoDTO?.id).to(equal(98765))
                    expect(repoDTO?.name).to(equal("awesome-repo"))
                    expect(repoDTO?.fullName).to(equal("testuser/awesome-repo"))
                    expect(repoDTO?.owner.id).to(equal(12345))
                    expect(repoDTO?.owner.login).to(equal("testuser"))
                    expect(repoDTO?.isPrivate).to(equal(false))
                    expect(repoDTO?.htmlUrl).to(equal("https://github.com/testuser/awesome-repo"))
                    expect(repoDTO?.description).to(equal("An awesome repository for testing"))
                    expect(repoDTO?.fork).to(equal(false))
                    expect(repoDTO?.language).to(equal("Swift"))
                    expect(repoDTO?.forksCount).to(equal(15))
                    expect(repoDTO?.stargazersCount).to(equal(80))
                    expect(repoDTO?.watchersCount).to(equal(8))
                    expect(repoDTO?.defaultBranch).to(equal("main"))
                    
                    // Verify topics
                    expect(repoDTO?.topics?.count).to(equal(3))
                    expect(repoDTO?.topics?[0]).to(equal("swift"))
                    expect(repoDTO?.topics?[1]).to(equal("ios"))
                    expect(repoDTO?.topics?[2]).to(equal("testing"))
                    
                    // Verify dates
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                    
                    let expectedCreatedDate = dateFormatter.date(from: "2023-01-15T10:30:00Z")
                    let expectedUpdatedDate = dateFormatter.date(from: "2023-06-20T14:45:30Z")
                    
                    expect(repoDTO?.createdAt).to(equal(expectedCreatedDate))
                    expect(repoDTO?.updatedAt).to(equal(expectedUpdatedDate))
                }
                
                it("should handle missing optional fields") {
                    // Given: A JSON with missing optional fields
                    let jsonData = loadJSON(from: "repository_response_missing_fields")
                    
                    // When
                    let repoDTO = try? decoder.decode(RepositoryResponseDTO.self, from: jsonData)
                    
                    // Then: Optional fields should be nil
                    expect(repoDTO).toNot(beNil())
                    expect(repoDTO?.id).to(equal(98765))
                    expect(repoDTO?.name).to(equal("awesome-repo"))
                    expect(repoDTO?.description).to(beNil())
                    expect(repoDTO?.language).to(beNil())
                    expect(repoDTO?.topics).to(beNil())
                }
            }
            
            // MARK: - UserSearchResponseDTO Tests
            
            context("UserSearchResponseDTO") {
                it("should decode correctly from valid JSON") {
                    // Given - Load JSON from file
                    let jsonData = loadJSON(from: "user_search_response")
                    
                    // When
                    let searchDTO = try? decoder.decode(UserSearchResponseDTO.self, from: jsonData)
                    
                    // Then
                    expect(searchDTO).toNot(beNil(), description: "The searchDTO object should not be nil")
                    expect(searchDTO?.totalCount).to(equal(2), description: "The totalCount should be 2")
                    expect(searchDTO?.items.count).to(equal(2), description: "There should be 2 items")
                    
                    // Verify the first user
                    let firstUser = searchDTO?.items[0]
                    expect(firstUser?.id).to(equal(12345), description: "The ID of the first user should be 12345")
                    expect(firstUser?.login).to(equal("testuser1"), description: "The login of the first user should be testuser1")
                    expect(firstUser?.name).to(equal("Test User One"), description: "The name of the first user should be Test User One")
                    
                    // Verify the second user
                    let secondUser = searchDTO?.items[1]
                    expect(secondUser?.id).to(equal(67890), description: "The ID of the second user should be 67890")
                    expect(secondUser?.login).to(equal("testuser2"), description: "The login of the second user should be testuser2")
                    expect(secondUser?.name).to(equal("Test User Two"), description: "The name of the second user should be Test User Two")
                }
            }
        }
    }
}