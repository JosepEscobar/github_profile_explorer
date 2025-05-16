import Foundation

struct OwnerResponseDTO: Decodable {
    let id: Int
    let login: String
    let avatarUrl: String
    let url: String
    let htmlUrl: String
} 