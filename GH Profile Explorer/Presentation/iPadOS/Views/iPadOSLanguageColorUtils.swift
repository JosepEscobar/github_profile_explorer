#if os(iOS)
import SwiftUI

struct iPadOSLanguageColorUtils {
    static func languageColor(for language: String) -> Color {
        switch language.lowercased() {
        case "swift":
            return .orange
        case "javascript", "typescript":
            return .yellow
        case "python":
            return .blue
        case "kotlin":
            return .purple
        case "java":
            return .red
        case "c++", "c":
            return .pink
        case "ruby":
            return .red
        case "go":
            return .cyan
        case "rust":
            return .brown
        case "html":
            return .orange
        case "css":
            return .blue
        case "php":
            return .purple
        case "dart":
            return .cyan
        case "shell", "bash":
            return .green
        default:
            return .gray
        }
    }
}
#endif 