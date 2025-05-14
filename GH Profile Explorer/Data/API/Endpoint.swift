import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public struct Endpoint {
    let baseURL: URL
    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]?
    let headers: [String: String]?
    let body: Data?
    
    public init(
        baseURL: URL = URL(string: "https://api.github.com")!,
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem]? = nil,
        headers: [String: String]? = ["Accept": "application/vnd.github.v3+json"],
        body: Data? = nil
    ) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.headers = headers
        self.body = body
    }
    
    var url: URL? {
        var components = URLComponents()
        components.scheme = baseURL.scheme
        components.host = baseURL.host
        components.path = path.hasPrefix("/") ? path : "/\(path)"
        components.queryItems = queryItems
        
        return components.url
    }
}

extension Endpoint {
    static func user(username: String) -> Endpoint {
        Endpoint(path: "/users/\(username)")
    }
    
    static func userRepositories(
        username: String,
        page: Int = 1,
        perPage: Int = 30
    ) -> Endpoint {
        Endpoint(
            path: "/users/\(username)/repos",
            queryItems: [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)"),
                URLQueryItem(name: "sort", value: "updated")
            ]
        )
    }
    
    static func searchUsers(
        query: String,
        page: Int = 1,
        perPage: Int = 30
    ) -> Endpoint {
        Endpoint(
            path: "/search/users",
            queryItems: [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)")
            ]
        )
    }
} 