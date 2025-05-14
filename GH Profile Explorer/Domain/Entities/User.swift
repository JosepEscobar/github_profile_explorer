import Foundation

public struct User: Identifiable, Equatable, Hashable {
    public let id: Int
    public let login: String
    public let name: String?
    public let avatarURL: URL
    public let bio: String?
    public let followers: Int
    public let following: Int
    public let location: String?
    public let publicRepos: Int
    public let publicGists: Int
    
    public init(
        id: Int,
        login: String,
        name: String?,
        avatarURL: URL,
        bio: String?,
        followers: Int,
        following: Int,
        location: String?,
        publicRepos: Int,
        publicGists: Int
    ) {
        self.id = id
        self.login = login
        self.name = name
        self.avatarURL = avatarURL
        self.bio = bio
        self.followers = followers
        self.following = following
        self.location = location
        self.publicRepos = publicRepos
        self.publicGists = publicGists
    }
    
    // Mock for previews and testing
    public static func mock() -> User {
        User(
            id: 1,
            login: "octocat",
            name: "The Octocat",
            avatarURL: URL(string: "https://github.com/images/error/octocat_happy.gif")!,
            bio: "Code enthusiast & open source contributor",
            followers: 20,
            following: 0,
            location: "San Francisco",
            publicRepos: 8,
            publicGists: 0
        )
    }
    
    // Implementación de Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
} 