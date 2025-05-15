import Foundation

public struct RepositoryUIModel: Identifiable {
    public let id: Int
    public let name: String
    public let description: String?
    public let language: String?
    public let stars: String
    public let forks: String
    public let watchers: String
    public let isForked: Bool
    public let topics: [String]
    public let htmlURL: URL
    public let ownerLogin: String
    public let ownerAvatarURL: URL
    
    public init(from domainModel: Repository) {
        self.id = domainModel.id
        self.name = domainModel.name
        self.description = domainModel.description
        self.language = domainModel.language
        self.stars = "\(domainModel.stargazersCount)"
        self.forks = "\(domainModel.forksCount)"
        self.watchers = "\(domainModel.watchersCount)"
        self.isForked = domainModel.fork
        self.topics = domainModel.topics
        self.htmlURL = domainModel.htmlURL
        self.ownerLogin = domainModel.owner.login
        self.ownerAvatarURL = domainModel.owner.avatarURL
    }
    
    public static func mock() -> RepositoryUIModel {
        RepositoryUIModel(from: Repository.mock())
    }
    
    public static func mockArray() -> [RepositoryUIModel] {
        Repository.mockArray().map { RepositoryUIModel(from: $0) }
    }
} 