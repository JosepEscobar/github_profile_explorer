#if os(iOS)
import SwiftUI

enum LanguageColorUtils {
    private enum Constants {
        enum Languages {
            static let swift = "swift"
            static let javascript = "javascript"
            static let typescript = "typescript"
            static let python = "python"
            static let kotlin = "kotlin"
            static let java = "java"
            static let cpp = "c++"
            static let c = "c"
            static let ruby = "ruby"
            static let go = "go"
            static let rust = "rust"
            static let html = "html"
            static let css = "css"
        }
        
        enum Colors {
            static let swift = Color.orange
            static let javascript = Color.yellow
            static let python = Color.blue
            static let kotlin = Color.purple
            static let java = Color.red
            static let cpp = Color.pink
            static let ruby = Color.red
            static let go = Color.cyan
            static let rust = Color.brown
            static let html = Color.orange
            static let css = Color.blue
            static let defaultColor = Color.gray
        }
    }
    
    static func color(for language: String) -> Color {
        switch language.lowercased() {
        case Constants.Languages.swift:
            return Constants.Colors.swift
        case Constants.Languages.javascript, Constants.Languages.typescript:
            return Constants.Colors.javascript
        case Constants.Languages.python:
            return Constants.Colors.python
        case Constants.Languages.kotlin:
            return Constants.Colors.kotlin
        case Constants.Languages.java:
            return Constants.Colors.java
        case Constants.Languages.cpp, Constants.Languages.c:
            return Constants.Colors.cpp
        case Constants.Languages.ruby:
            return Constants.Colors.ruby
        case Constants.Languages.go:
            return Constants.Colors.go
        case Constants.Languages.rust:
            return Constants.Colors.rust
        case Constants.Languages.html:
            return Constants.Colors.html
        case Constants.Languages.css:
            return Constants.Colors.css
        default:
            return Constants.Colors.defaultColor
        }
    }
}
#endif 