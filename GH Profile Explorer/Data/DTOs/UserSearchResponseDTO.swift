import Foundation

struct UserSearchResponseDTO: Decodable {
    let items: [UserResponseDTO]
    let totalCount: Int
    
    enum CodingKeys: String, CodingKey {
        case items
        case totalCount = "total_count"
    }
} 