#if os(iOS)
import Foundation

public struct UserUIModel: Identifiable {
    public let id: String
    public let login: String
    public let name: String
    public let avatarURL: URL
    public let bio: String?
    public let location: String?
    public let followers: String
    public let publicRepos: String
    
    public init(from domainModel: User) {
        self.id = domainModel.login
        self.login = domainModel.login
        self.name = domainModel.name ?? domainModel.login
        self.avatarURL = domainModel.avatarURL
        self.bio = domainModel.bio
        self.location = domainModel.location
        self.followers = "\(domainModel.followers)"
        self.publicRepos = "\(domainModel.publicRepos)"
    }
    
    public static func mock() -> UserUIModel {
        UserUIModel(from: User.mock())
    }
}
#endif 