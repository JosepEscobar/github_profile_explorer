import Foundation

public struct LanguageStat {
    public let language: String
    public let count: Int
    
    public init(language: String, count: Int) {
        self.language = language
        self.count = count
    }
} 