import Foundation
import SwiftUI

public struct LanguageStatUIModel: Identifiable {
    public var id: String { language }
    public let language: String
    public let count: Int
    
    public init(language: String, count: Int) {
        self.language = language
        self.count = count
    }
} 