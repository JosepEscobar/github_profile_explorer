import SwiftUI

public struct RepositoryItemView: View {
    private let repository: Repository
    private let showOwner: Bool
    private let onTap: (Repository) -> Void
    
    public init(
        repository: Repository,
        showOwner: Bool = false,
        onTap: @escaping (Repository) -> Void = { _ in }
    ) {
        self.repository = repository
        self.showOwner = showOwner
        self.onTap = onTap
    }
    
    public var body: some View {
        Button {
            onTap(repository)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    // Repository icon
                    Image(systemName: repository.fork ? "tuningfork" : "book.closed")
                        .foregroundColor(repository.fork ? .orange : .blue)
                        .font(.system(size: 18, weight: .medium))
                        .frame(width: 24, height: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(repository.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        if showOwner {
                            Text(repository.owner.login)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        // Stars
                        Label("\(repository.stargazersCount)", systemImage: "star.fill")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        // Forks
                        if repository.forksCount > 0 {
                            Label("\(repository.forksCount)", systemImage: "tuningfork")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if let description = repository.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .padding(.leading, 24)
                }
                
                HStack(spacing: 12) {
                    // Language indicator
                    if let language = repository.language {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(languageColor(for: language))
                                .frame(width: 8, height: 8)
                            Text(language)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Topics
                    if !repository.topics.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(repository.topics.prefix(3), id: \.self) { topic in
                                    Text(topic)
                                        .font(.system(size: 10))
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(4)
                                }
                                
                                if repository.topics.count > 3 {
                                    Text("+\(repository.topics.count - 3)")
                                        .font(.system(size: 10))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.leading, 24)
                    }
                }
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private func languageColor(for language: String) -> Color {
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
        default:
            return .gray
        }
    }
}

#Preview {
    VStack {
        RepositoryItemView(repository: Repository.mock())
            .padding()
            .background(Color.secondary.opacity(0.05))
        
        RepositoryItemView(repository: Repository.mockArray()[2], showOwner: true)
            .padding()
            .background(Color.secondary.opacity(0.05))
    }
    .padding()
} 