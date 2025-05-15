import Foundation

public struct UserUIModel: Identifiable {
    public let id: String
    public let login: String
    public let name: String
    public let avatarURL: URL
    public let bio: String?
    public let location: String?
    public let followers: String
    public let following: String
    public let publicRepos: String
    public let publicGists: String
    
    public init(from domainModel: User) {
        self.id = domainModel.login
        self.login = domainModel.login
        self.name = domainModel.name ?? domainModel.login
        self.avatarURL = domainModel.avatarURL
        self.bio = domainModel.bio
        self.location = domainModel.location
        self.followers = "\(domainModel.followers)"
        self.following = "\(domainModel.following)"
        self.publicRepos = "\(domainModel.publicRepos)"
        self.publicGists = "\(domainModel.publicGists)"
    }
    
    public static func mock() -> UserUIModel {
        UserUIModel(from: User.mock())
    }
} 