#if os(iOS)
import Foundation

public struct RepositoryUIModel: Identifiable {
    public let id: Int
    public let name: String
    public let description: String?
    public let language: String?
    public let stars: String
    public let forks: String
    public let isForked: Bool
    
    public init(from domainModel: Repository) {
        self.id = domainModel.id
        self.name = domainModel.name
        self.description = domainModel.description
        self.language = domainModel.language
        self.stars = "\(domainModel.stargazersCount)"
        self.forks = "\(domainModel.forksCount)"
        self.isForked = domainModel.fork
    }
    
    public static func mock() -> RepositoryUIModel {
        RepositoryUIModel(from: Repository.mock())
    }
    
    public static func mockArray() -> [RepositoryUIModel] {
        Repository.mockArray().map { RepositoryUIModel(from: $0) }
    }
}
#endif 