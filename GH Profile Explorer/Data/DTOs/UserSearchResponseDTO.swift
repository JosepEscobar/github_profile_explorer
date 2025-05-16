import Foundation

struct UserSearchResponseDTO: Decodable {
    let items: [UserResponseDTO]
    let totalCount: Int
}
