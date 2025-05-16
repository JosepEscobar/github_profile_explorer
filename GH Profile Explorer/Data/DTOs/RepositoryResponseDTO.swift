import Foundation

struct RepositoryResponseDTO: Decodable {
    let id: Int
    let name: String
    let fullName: String
    let owner: OwnerResponseDTO
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