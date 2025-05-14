import Foundation

public protocol NetworkClientProtocol {
    func fetch<T: Decodable>(endpoint: Endpoint) async throws -> T
}

public final class NetworkClient: NetworkClientProtocol {
    private let urlSession: URLSession
    
    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    public func fetch<T: Decodable>(endpoint: Endpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw AppError.unexpectedError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        
        if let body = endpoint.body {
            request.httpBody = body
        }
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AppError.networkError
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    decoder.dateDecodingStrategy = .iso8601
                    return try decoder.decode(T.self, from: data)
                } catch {
                    throw AppError.decodingError
                }
            case 404:
                throw AppError.userNotFound
            case 400...499:
                throw AppError.unexpectedError("Client error: \(httpResponse.statusCode)")
            case 500...599:
                throw AppError.serverError(code: httpResponse.statusCode)
            default:
                throw AppError.unexpectedError("Unexpected status code: \(httpResponse.statusCode)")
            }
        } catch is URLError {
            throw AppError.networkError
        } catch {
            if let appError = error as? AppError {
                throw appError
            }
            throw AppError.unexpectedError(error.localizedDescription)
        }
    }
} 