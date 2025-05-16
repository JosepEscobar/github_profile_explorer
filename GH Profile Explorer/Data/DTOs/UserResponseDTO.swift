import Foundation

struct UserResponseDTO: Decodable {
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
} 