import Foundation

public struct Repository: Identifiable, Equatable, Hashable {
    public let id: Int
    public let name: String
    public let fullName: String
    public let owner: User
    public let isPrivate: Bool
    public let htmlURL: URL
    public let description: String?
    public let fork: Bool
    public let language: String?
    public let forksCount: Int
    public let stargazersCount: Int
    public let watchersCount: Int
    public let defaultBranch: String
    public let createdAt: Date
    public let updatedAt: Date
    public let topics: [String]
    
    public init(
        id: Int,
        name: String,
        fullName: String,
        owner: User,
        isPrivate: Bool,
        htmlURL: URL,
        description: String?,
        fork: Bool,
        language: String?,
        forksCount: Int,
        stargazersCount: Int,
        watchersCount: Int,
        defaultBranch: String,
        createdAt: Date,
        updatedAt: Date,
        topics: [String]
    ) {
        self.id = id
        self.name = name
        self.fullName = fullName
        self.owner = owner
        self.isPrivate = isPrivate
        self.htmlURL = htmlURL
        self.description = description
        self.fork = fork
        self.language = language
        self.forksCount = forksCount
        self.stargazersCount = stargazersCount
        self.watchersCount = watchersCount
        self.defaultBranch = defaultBranch
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.topics = topics
    }
    
    // Mock for previews and testing
    public static func mock() -> Repository {
        Repository(
            id: 1296269,
            name: "Hello-World",
            fullName: "octocat/Hello-World",
            owner: User.mock(),
            isPrivate: false,
            htmlURL: URL(string: "https://github.com/octocat/Hello-World")!,
            description: "This is your first repository!",
            fork: false,
            language: "Swift",
            forksCount: 9,
            stargazersCount: 80,
            watchersCount: 80,
            defaultBranch: "main",
            createdAt: Date(),
            updatedAt: Date(),
            topics: ["swift", "ios", "swiftui"]
        )
    }
    
    public static func mockArray() -> [Repository] {
        let languages = ["Swift", "JavaScript", "Python", "Kotlin", "C++", nil]
        let topics = [
            ["swift", "ios", "swiftui"],
            ["javascript", "react", "web"],
            ["python", "data-science", "machine-learning"],
            ["android", "kotlin", "mobile"],
            ["cpp", "algorithms", "data-structures"],
            ["documentation", "guides"]
        ]
        
        return (0..<10).map { index in
            Repository(
                id: 1296269 + index,
                name: "Repo-\(index + 1)",
                fullName: "octocat/Repo-\(index + 1)",
                owner: User.mock(),
                isPrivate: false,
                htmlURL: URL(string: "https://github.com/octocat/Repo-\(index + 1)")!,
                description: "Repository description \(index + 1)",
                fork: index % 3 == 0,
                language: languages[index % languages.count],
                forksCount: 9 + index,
                stargazersCount: 80 + index * 5,
                watchersCount: 80 + index * 2,
                defaultBranch: "main",
                createdAt: Date(),
                updatedAt: Date(),
                topics: topics[index % topics.count]
            )
        }
    }
    
    // Hashable implementation
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Repository, rhs: Repository) -> Bool {
        lhs.id == rhs.id
    }
} 