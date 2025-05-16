import Foundation
extension Endpoint {
    static func userRepositories(
        username: String,
        page: Int = 1,
        perPage: Int = 30
    ) -> Endpoint {
        Endpoint(
            path: "/users/\(username)/repos",
            queryItems: [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)"),
                URLQueryItem(name: "sort", value: "updated")
            ]
        )
    }
}
