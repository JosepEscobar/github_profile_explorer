import Foundation
extension Endpoint {
    static func user(username: String) -> Endpoint {
        Endpoint(path: "/users/\(username)")
    }
}
