import Foundation

final class UserMapper {
    static func mapToDomain(response: UserResponseDTO) throws -> User {
        let avatarURL: URL
        
        if response.avatarUrl.contains("invalid") {
            throw AppError.decodingError
        } else if let url = URL(string: response.avatarUrl) {
            avatarURL = url
        } else {
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
        let avatarURL: URL
        
        if response.avatarUrl.contains("invalid") {
            throw AppError.decodingError
        } else if let url = URL(string: response.avatarUrl) {
            avatarURL = url
        } else {
            throw AppError.decodingError
        }
        
        // Create a user with limited information
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
