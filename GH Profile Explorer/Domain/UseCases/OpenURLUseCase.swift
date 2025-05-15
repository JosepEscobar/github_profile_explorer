import Foundation

public protocol OpenURLUseCaseProtocol {
    func createGitHubProfileURL(for username: String) -> URL?
    func createRepositoryURL(for repository: Repository) -> URL
}

public final class OpenURLUseCase: OpenURLUseCaseProtocol {
    private enum Constants {
        enum URLs {
            static let githubBaseURL = "https://github.com/"
        }
    }
    
    public init() {}
    
    public func createGitHubProfileURL(for username: String) -> URL? {
        return URL(string: Constants.URLs.githubBaseURL + username)
    }
    
    public func createRepositoryURL(for repository: Repository) -> URL {
        return repository.htmlURL
    }
} 