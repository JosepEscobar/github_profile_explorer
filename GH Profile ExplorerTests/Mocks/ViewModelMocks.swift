import Foundation
@testable import GH_Profile_Explorer

// MARK: - Shared Mock Classes for ViewModels
class MockSearchHistoryUseCase: ManageSearchHistoryUseCaseProtocol {
    var mockHistory: [String] = []
    
    var loadHistoryCalled = false
    var loadHistoryPlatform: Platform?
    
    var addToHistoryCalled = false
    var addToHistoryUsername: String?
    var addToHistoryPlatform: Platform?
    
    var removeFromHistoryCalled = false
    var removeFromHistoryUsername: String?
    var removeFromHistoryPlatform: Platform?
    
    var clearHistoryCalled = false
    var clearHistoryPlatform: Platform?
    
    func loadSearchHistory(for platform: Platform) -> [String] {
        loadHistoryCalled = true
        loadHistoryPlatform = platform
        return mockHistory
    }
    
    func addToSearchHistory(username: String, platform: Platform) {
        addToHistoryCalled = true
        addToHistoryUsername = username
        addToHistoryPlatform = platform
    }
    
    func removeFromHistory(username: String, platform: Platform) {
        removeFromHistoryCalled = true
        removeFromHistoryUsername = username
        removeFromHistoryPlatform = platform
    }
    
    func clearSearchHistory(for platform: Platform) {
        clearHistoryCalled = true
        clearHistoryPlatform = platform
        mockHistory = []
    }
}

class MockOpenURLUseCase: OpenURLUseCaseProtocol {
    var mockProfileURL: URL = URL(string: "https://github.com/default")!
    var mockRepositoryURL: URL = URL(string: "https://github.com/default/repo")!
    
    var createGitHubProfileURLCalled = false
    var createGitHubProfileURLUsername: String?
    
    var createRepositoryURLCalled = false
    var createRepositoryURLRepository: Repository?
    
    func createGitHubProfileURL(for username: String) -> URL? {
        createGitHubProfileURLCalled = true
        createGitHubProfileURLUsername = username
        return mockProfileURL
    }
    
    func createRepositoryURL(for repository: Repository) -> URL {
        createRepositoryURLCalled = true
        createRepositoryURLRepository = repository
        return mockRepositoryURL
    }
}

class MockFilterRepositoriesUseCase: FilterRepositoriesUseCaseProtocol {
    var mockFilteredRepositories: [Repository] = []
    var mockLanguages: [String] = []
    
    var filterBySearchTextCalled = false
    var filterBySearchTextRepositories: [Repository]?
    var filterBySearchTextSearchText: String?
    
    var filterByLanguageCalled = false
    var filterByLanguageRepositories: [Repository]?
    var filterByLanguageLanguage: String?
    
    var filterBySearchTextAndLanguageCalled = false
    var filterRepositories: [Repository]?
    var filterSearchText: String?
    var filterLanguage: String?
    
    var extractUniqueLanguagesCalled = false
    var extractUniqueLanguagesRepositories: [Repository]?
    
    func filterBySearchText(repositories: [Repository], searchText: String) -> [Repository] {
        filterBySearchTextCalled = true
        filterBySearchTextRepositories = repositories
        filterBySearchTextSearchText = searchText
        return mockFilteredRepositories
    }
    
    func filterByLanguage(repositories: [Repository], language: String?) -> [Repository] {
        filterByLanguageCalled = true
        filterByLanguageRepositories = repositories
        filterByLanguageLanguage = language
        return mockFilteredRepositories
    }
    
    func filterBySearchTextAndLanguage(repositories: [Repository], searchText: String, language: String?) -> [Repository] {
        filterBySearchTextAndLanguageCalled = true
        filterRepositories = repositories
        filterSearchText = searchText
        filterLanguage = language
        return mockFilteredRepositories
    }
    
    func extractUniqueLanguages(from repositories: [Repository]) -> [String] {
        extractUniqueLanguagesCalled = true
        extractUniqueLanguagesRepositories = repositories
        return mockLanguages
    }
}

class MockCalculateLanguageStatsUseCase: CalculateLanguageStatsUseCaseProtocol {
    var mockStats: [LanguageStat] = []
    
    var executeForCalled = false
    var executeForRepositories: [Repository]?
    
    func execute(for repositories: [Repository]) -> [LanguageStat] {
        executeForCalled = true
        executeForRepositories = repositories
        return mockStats
    }
}

class MockFavoritesUseCase: ManageFavoritesUseCaseProtocol {
    var mockFavorites: [String] = []
    var mockIsFavorite: Bool = false
    
    var loadFavoritesCalled = false
    var addToFavoritesCalled = false
    var addToFavoritesUsername: String?
    var removeFromFavoritesCalled = false
    var removeFromFavoritesUsername: String?
    var isFavoriteCalled = false
    var isFavoriteUsername: String?
    var toggleFavoriteCalled = false
    var toggleFavoriteUsername: String?
    
    func loadFavorites() -> [String] {
        loadFavoritesCalled = true
        return mockFavorites
    }
    
    func addToFavorites(username: String) {
        addToFavoritesCalled = true
        addToFavoritesUsername = username
    }
    
    func removeFromFavorites(username: String) {
        removeFromFavoritesCalled = true
        removeFromFavoritesUsername = username
    }
    
    func isFavorite(username: String) -> Bool {
        isFavoriteCalled = true
        isFavoriteUsername = username
        return mockIsFavorite
    }
    
    func toggleFavorite(username: String) {
        toggleFavoriteCalled = true
        toggleFavoriteUsername = username
    }
}

// Mocks para casos de uso asíncronos
class MockFetchUserUseCase: FetchUserUseCaseProtocol {
    var mockResult: Result<User, Error> = .success(User.createMock())
    var executeCalled = false
    var executeUsername: String?
    var executeWithContinuation: ((CheckedContinuation<User, Error>) -> Void)?
    
    func execute(username: String) async throws -> User {
        executeCalled = true
        executeUsername = username
        
        if let executeWithContinuation = executeWithContinuation {
            return try await withCheckedThrowingContinuation { continuation in
                executeWithContinuation(continuation)
            }
        }
        
        switch mockResult {
        case .success(let user):
            return user
        case .failure(let error):
            throw error
        }
    }
    
    // Este método es para simular la ejecución asíncrona en los tests
    func completeExecution() {
        // Método de compatibilidad con tests antiguos
    }
}

class MockFetchRepositoriesUseCase: FetchUserRepositoriesUseCaseProtocol {
    var mockResult: Result<[Repository], Error> = .success([Repository.createMock()])
    var executeCalled = false
    var executeUsername: String?
    var executeWithContinuation: ((CheckedContinuation<[Repository], Error>) -> Void)?
    
    func execute(username: String) async throws -> [Repository] {
        executeCalled = true
        executeUsername = username
        
        if let executeWithContinuation = executeWithContinuation {
            return try await withCheckedThrowingContinuation { continuation in
                executeWithContinuation(continuation)
            }
        }
        
        switch mockResult {
        case .success(let repositories):
            return repositories
        case .failure(let error):
            throw error
        }
    }
    
    // Este método es para simular la ejecución asíncrona en los tests
    func completeExecution() {
        // Método de compatibilidad con tests antiguos
    }
}

// MARK: - Model Extensions for Testing
extension User {
    static func createMock() -> User {
        return User(
            id: 1,
            login: "testuser",
            name: "Test User",
            avatarURL: URL(string: "https://github.com/testuser.png")!,
            bio: "This is a test user",
            followers: 100,
            following: 50,
            location: "Test City",
            publicRepos: 25,
            publicGists: 10
        )
    }
}

extension Repository {
    static func createMock(id: Int = 1) -> Repository {
        return Repository(
            id: id,
            name: "test-repo",
            fullName: "testuser/test-repo",
            owner: User.createMock(),
            isPrivate: false,
            htmlURL: URL(string: "https://github.com/testuser/test-repo")!,
            description: "This is a test repository",
            fork: false,
            language: "Swift",
            forksCount: 10,
            stargazersCount: 50,
            watchersCount: 5,
            defaultBranch: "main",
            createdAt: Date(),
            updatedAt: Date(),
            topics: ["swift", "ios", "test"]
        )
    }
} 