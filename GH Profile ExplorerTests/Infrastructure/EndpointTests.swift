import Quick
import Nimble
import Foundation
@testable import GH_Profile_Explorer

class EndpointTests: QuickSpec {
    override class func spec() {
        describe("Endpoint") {
            context("when creating a URL") {
                it("should create the correct URL with path") {
                    // Given
                    let endpoint = Endpoint(path: "/test")
                    
                    // When
                    let url = endpoint.url
                    
                    // Then
                    expect(url?.absoluteString).to(equal("https://api.github.com/test"))
                }
                
                it("should create the correct URL with path without leading slash") {
                    // Given
                    let endpoint = Endpoint(path: "test")
                    
                    // When
                    let url = endpoint.url
                    
                    // Then
                    expect(url?.absoluteString).to(equal("https://api.github.com/test"))
                }
                
                it("should create the correct URL with query parameters") {
                    // Given
                    let endpoint = Endpoint(
                        path: "/test",
                        queryItems: [
                            URLQueryItem(name: "param1", value: "value1"),
                            URLQueryItem(name: "param2", value: "value2")
                        ]
                    )
                    
                    // When
                    let url = endpoint.url
                    
                    // Then
                    expect(url?.absoluteString).to(equal("https://api.github.com/test?param1=value1&param2=value2"))
                }
                
                it("should create the correct URL with custom base URL") {
                    // Given
                    let endpoint = Endpoint(
                        baseURL: URL(string: "https://example.com")!,
                        path: "/test"
                    )
                    
                    // When
                    let url = endpoint.url
                    
                    // Then
                    expect(url?.absoluteString).to(equal("https://example.com/test"))
                }
            }
            
            context("when using factory methods") {
                it("should create correct user endpoint") {
                    // Given
                    let endpoint = Endpoint.user(username: "testuser")
                    
                    // When
                    let url = endpoint.url
                    
                    // Then
                    expect(url?.absoluteString).to(equal("https://api.github.com/users/testuser"))
                    expect(endpoint.method).to(equal(.get))
                }
                
                it("should create correct user repositories endpoint") {
                    // Given
                    let endpoint = Endpoint.userRepositories(username: "testuser")
                    
                    // When
                    let url = endpoint.url
                    
                    // Then
                    expect(url?.absoluteString).to(equal("https://api.github.com/users/testuser/repos?page=1&per_page=30&sort=updated"))
                    expect(endpoint.method).to(equal(.get))
                }
                
                it("should create correct user repositories endpoint with pagination") {
                    // Given
                    let endpoint = Endpoint.userRepositories(username: "testuser", page: 2, perPage: 10)
                    
                    // When
                    let url = endpoint.url
                    
                    // Then
                    expect(url?.absoluteString).to(equal("https://api.github.com/users/testuser/repos?page=2&per_page=10&sort=updated"))
                }
                
                it("should create correct search users endpoint") {
                    // Given
                    let endpoint = Endpoint.searchUsers(query: "test")
                    
                    // When
                    let url = endpoint.url
                    
                    // Then
                    expect(url?.absoluteString).to(equal("https://api.github.com/search/users?q=test&page=1&per_page=30"))
                    expect(endpoint.method).to(equal(.get))
                }
                
                it("should create correct search users endpoint with pagination") {
                    // Given
                    let endpoint = Endpoint.searchUsers(query: "test", page: 3, perPage: 15)
                    
                    // When
                    let url = endpoint.url
                    
                    // Then
                    expect(url?.absoluteString).to(equal("https://api.github.com/search/users?q=test&page=3&per_page=15"))
                }
            }
        }
    }
} 