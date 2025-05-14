import Foundation

struct UserResponse: Decodable {
    let id: Int
    let login: String
    let name: String?
    let avatarUrl: String
    let bio: String?
    let followers: Int
    let following: Int
    let location: String?
    let publicRepos: Int
    let publicGists: Int
    
    enum CodingKeys: String, CodingKey {
        case id, login, name, bio, followers, following, location
        case avatarUrl = "avatar_url"
        case publicRepos = "public_repos"
        case publicGists = "public_gists"
    }
}

struct UserSearchResponse: Decodable {
    let items: [UserResponse]
    let totalCount: Int
    
    enum CodingKeys: String, CodingKey {
        case items
        case totalCount = "total_count"
    }
}

final class UserMapper {
    static func mapToDomain(response: UserResponse) throws -> User {
        guard let avatarURL = URL(string: response.avatarUrl) else {
            throw AppError.decodingError
        }
        
        return User(
            id: response.id,
            login: response.login,
            name: response.name,
            avatarURL: avatarURL,
            bio: response.bio,
            followers: response.followers,
            following: response.following,
            location: response.location,
            publicRepos: response.publicRepos,
            publicGists: response.publicGists
        )
    }
    
    static func mapToDomain(responses: [UserResponse]) throws -> [User] {
        try responses.map { try mapToDomain(response: $0) }
    }
    
    static func mapSearchResponseToDomain(response: UserSearchResponse) throws -> [User] {
        try response.items.map { try mapToDomain(response: $0) }
    }
} 