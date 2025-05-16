import Foundation

public protocol FilterRepositoriesUseCaseProtocol {
    func filterBySearchText(repositories: [Repository], searchText: String) -> [Repository]
    func filterByLanguage(repositories: [Repository], language: String?) -> [Repository]
    func filterBySearchTextAndLanguage(repositories: [Repository], searchText: String, language: String?) -> [Repository]
    func extractUniqueLanguages(from repositories: [Repository]) -> [String]
}

public final class FilterRepositoriesUseCase: FilterRepositoriesUseCaseProtocol {
    public init() {}
    
    public func filterBySearchText(repositories: [Repository], searchText: String) -> [Repository] {
        guard !searchText.isEmpty else {
            return repositories
        }
        
        return repositories.filter { repo in
            repo.name.localizedCaseInsensitiveContains(searchText) ||
            (repo.description?.localizedCaseInsensitiveContains(searchText) ?? false) ||
            (repo.language?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    public func filterByLanguage(repositories: [Repository], language: String?) -> [Repository] {
        guard let language = language else {
            return repositories
        }
        
        return repositories.filter { $0.language == language }
    }
    
    public func filterBySearchTextAndLanguage(repositories: [Repository], searchText: String, language: String?) -> [Repository] {
        let textFiltered = filterBySearchText(repositories: repositories, searchText: searchText)
        return filterByLanguage(repositories: textFiltered, language: language)
    }
    
    public func extractUniqueLanguages(from repositories: [Repository]) -> [String] {
        let allLanguages = repositories.compactMap { $0.language }
        return Array(Set(allLanguages)).sorted()
    }
} 