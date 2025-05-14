import Foundation

struct RepositoryResponse: Decodable {
    let id: Int
    let name: String
    let fullName: String
    let owner: OwnerResponse
    let isPrivate: Bool
    let htmlUrl: String
    let description: String?
    let fork: Bool
    let language: String?
    let forksCount: Int
    let stargazersCount: Int
    let watchersCount: Int
    let defaultBranch: String
    let createdAt: Date
    let updatedAt: Date
    let topics: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, fullName, owner, htmlUrl, description, fork, language
        case forksCount, stargazersCount, watchersCount, defaultBranch
        case createdAt, updatedAt, topics
        case isPrivate = "private"
    }
}

final class RepositoryMapper {
    static func mapToDomain(response: RepositoryResponse) throws -> Repository {
        guard let htmlURL = URL(string: response.htmlUrl) else {
            throw AppError.decodingError
        }
        
        let user = try UserMapper.mapOwnerToDomain(response: response.owner)
        
        return Repository(
            id: response.id,
            name: response.name,
            fullName: response.fullName,
            owner: user,
            isPrivate: response.isPrivate,
            htmlURL: htmlURL,
            description: response.description,
            fork: response.fork,
            language: response.language,
            forksCount: response.forksCount,
            stargazersCount: response.stargazersCount,
            watchersCount: response.watchersCount,
            defaultBranch: response.defaultBranch,
            createdAt: response.createdAt,
            updatedAt: response.updatedAt,
            topics: response.topics ?? []
        )
    }
    
    static func mapToDomain(responses: [RepositoryResponse]) throws -> [Repository] {
        try responses.map { try mapToDomain(response: $0) }
    }
} 