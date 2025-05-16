import Foundation
extension Endpoint {
    static func searchUsers(
        query: String,
        page: Int = 1,
        perPage: Int = 30
    ) -> Endpoint {
        Endpoint(
            path: "/search/users",
            queryItems: [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)")
            ]
        )
    }
}
