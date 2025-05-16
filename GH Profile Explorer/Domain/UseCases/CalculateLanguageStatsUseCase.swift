import Foundation

public protocol CalculateLanguageStatsUseCaseProtocol {
    func execute(for repositories: [Repository]) -> [LanguageStat]
}

public final class CalculateLanguageStatsUseCase: CalculateLanguageStatsUseCaseProtocol {
    public init() {}
    
    public func execute(for repositories: [Repository]) -> [LanguageStat] {
        var languageCounts: [String: Int] = [:]
        
        for repo in repositories {
            if let language = repo.language {
                languageCounts[language, default: 0] += 1
            }
        }
        
        return languageCounts.map { language, count in
            LanguageStat(language: language, count: count)
        }.sorted { $0.count > $1.count }
    }
} 