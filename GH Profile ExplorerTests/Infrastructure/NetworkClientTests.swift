import Quick
import Nimble
import Foundation
@testable import GH_Profile_Explorer

class NetworkClientTests: QuickSpec {
    override class func spec() {
        var networkClient: NetworkClient!
        var mockURLSession: MockURLSession!
        
        beforeEach {
            mockURLSession = MockURLSession()
            networkClient = NetworkClient(urlSession: mockURLSession)
        }
        
        describe("NetworkClient") {
            context("when fetching data successfully") {
                it("should decode the response correctly") {
                    // Given
                    let jsonData = """
                    {
                        "id": 1,
                        "login": "testuser",
                        "name": "Test User",
                        "avatar_url": "https://example.com/avatar.png",
                        "bio": "Test bio",
                        "followers": 10,
                        "following": 5,
                        "location": "Test Location",
                        "public_repos": 20,
                        "public_gists": 3
                    }
                    """.data(using: .utf8)!
                    
                    let response = HTTPURLResponse(
                        url: URL(string: "https://api.github.com/users/testuser")!,
                        statusCode: 200,
                        httpVersion: nil,
                        headerFields: nil
                    )
                    
                    mockURLSession.mockData = jsonData
                    mockURLSession.mockResponse = response
                    
                    // When
                    waitUntil { done in
                        Task {
                            do {
                                let result: UserResponseDTO = try await networkClient.fetch(endpoint: .user(username: "testuser"))
                                
                                // Then
                                expect(result.id).to(equal(1))
                                expect(result.login).to(equal("testuser"))
                                expect(result.name).to(equal("Test User"))
                                expect(result.avatarUrl).to(equal("https://example.com/avatar.png"))
                                expect(result.bio).to(equal("Test bio"))
                                expect(result.followers).to(equal(10))
                                expect(result.following).to(equal(5))
                                expect(result.location).to(equal("Test Location"))
                                expect(result.publicRepos).to(equal(20))
                                expect(result.publicGists).to(equal(3))
                                
                                done()
                            } catch {
                                fail("Expected success but got error: \(error)")
                                done()
                            }
                        }
                    }
                }
            }
            
            context("when receiving an error status code") {
                it("should throw UserNotFound for 404") {
                    // Given
                    let response = HTTPURLResponse(
                        url: URL(string: "https://api.github.com/users/nonexistentuser")!,
                        statusCode: 404,
                        httpVersion: nil,
                        headerFields: nil
                    )
                    
                    mockURLSession.mockData = Data()
                    mockURLSession.mockResponse = response
                    
                    // When & Then
                    waitUntil { done in
                        Task {
                            do {
                                let _: UserResponseDTO = try await networkClient.fetch(endpoint: .user(username: "nonexistentuser"))
                                fail("Expected to throw an error")
                                done()
                            } catch {
                                expect(error).to(matchError(AppError.userNotFound))
                                done()
                            }
                        }
                    }
                }
                
                it("should throw ServerError for 500") {
                    // Given
                    let response = HTTPURLResponse(
                        url: URL(string: "https://api.github.com/users/testuser")!,
                        statusCode: 500,
                        httpVersion: nil,
                        headerFields: nil
                    )
                    
                    mockURLSession.mockData = Data()
                    mockURLSession.mockResponse = response
                    
                    // When & Then
                    waitUntil { done in
                        Task {
                            do {
                                let _: UserResponseDTO = try await networkClient.fetch(endpoint: .user(username: "testuser"))
                                fail("Expected to throw an error")
                                done()
                            } catch {
                                expect(error).to(matchError(AppError.serverError(code: 500)))
                                done()
                            }
                        }
                    }
                }
            }
            
            context("when there is a network error") {
                it("should throw NetworkError") {
                    // Given
                    mockURLSession.mockError = URLError(.notConnectedToInternet)
                    
                    // When & Then
                    waitUntil { done in
                        Task {
                            do {
                                let _: UserResponseDTO = try await networkClient.fetch(endpoint: .user(username: "testuser"))
                                fail("Expected to throw an error")
                                done()
                            } catch {
                                expect(error).to(matchError(AppError.networkError))
                                done()
                            }
                        }
                    }
                }
            }
            
            context("when there is a decoding error") {
                it("should throw DecodingError") {
                    // Given
                    let invalidJSON = "{\"invalid\": json}".data(using: .utf8)!
                    let response = HTTPURLResponse(
                        url: URL(string: "https://api.github.com/users/testuser")!,
                        statusCode: 200,
                        httpVersion: nil,
                        headerFields: nil
                    )
                    
                    mockURLSession.mockData = invalidJSON
                    mockURLSession.mockResponse = response
                    
                    // When & Then
                    waitUntil { done in
                        Task {
                            do {
                                let _: UserResponseDTO = try await networkClient.fetch(endpoint: .user(username: "testuser"))
                                fail("Expected to throw an error")
                                done()
                            } catch {
                                expect(error).to(matchError(AppError.decodingError))
                                done()
                            }
                        }
                    }
                }
            }
        }
    }
}

// Implementa el protocolo URLSessionProtocol en vez de heredar de URLSession
class MockURLSession: URLSessionProtocol {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        
        guard let data = mockData, let response = mockResponse else {
            throw NSError(domain: "MockURLSession", code: 1, userInfo: nil)
        }
        
        return (data, response)
    }
} 