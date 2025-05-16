import Foundation

final class RepositoryMapper {
    static func mapToDomain(response: RepositoryResponseDTO) throws -> Repository {
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
    
    static func mapToDomain(responses: [RepositoryResponseDTO]) throws -> [Repository] {
        try responses.map { try mapToDomain(response: $0) }
    }
} 
