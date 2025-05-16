import Foundation

// Modelo para el endpoint /users/{username}
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
    
    // No necesitamos CodingKeys para la mayoría de los campos gracias a .convertFromSnakeCase
}

// Modelo simplificado para el campo 'owner' en repositorios
struct OwnerResponse: Decodable {
    let id: Int
    let login: String
    let avatarUrl: String
    let url: String
    let htmlUrl: String
    
    // No necesitamos CodingKeys gracias a .convertFromSnakeCase
}

struct UserSearchResponse: Decodable {
    let items: [UserResponse]
    let totalCount: Int
    
    // Solo necesitamos definir totalCount porque no sigue un patrón estándar
    enum CodingKeys: String, CodingKey {
        case items
        case totalCount = "total_count"
    }
}

final class UserMapper {
    static func mapToDomain(response: UserResponseDTO) throws -> User {
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
    
    static func mapOwnerToDomain(response: OwnerResponseDTO) throws -> User {
        guard let avatarURL = URL(string: response.avatarUrl) else {
            throw AppError.decodingError
        }
        
        // Creamos un usuario con información limitada
        return User(
            id: response.id,
            login: response.login,
            name: nil,
            avatarURL: avatarURL,
            bio: nil,
            followers: 0,
            following: 0,
            location: nil,
            publicRepos: 0,
            publicGists: 0
        )
    }
    
    static func mapToDomain(responses: [UserResponseDTO]) throws -> [User] {
        try responses.map { try mapToDomain(response: $0) }
    }
    
    static func mapSearchResponseToDomain(response: UserSearchResponseDTO) throws -> [User] {
        try response.items.map { try mapToDomain(response: $0) }
    }
} 
