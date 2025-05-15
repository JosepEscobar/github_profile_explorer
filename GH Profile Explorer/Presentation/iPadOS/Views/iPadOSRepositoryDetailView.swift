#if os(iOS)
import SwiftUI

struct iPadOSRepositoryDetailView: View {
    let repository: Repository
    var onOpenRepository: (Repository) -> Void
    
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
        default:
            return .gray
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(repository.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        if let language = repository.language {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(languageColor(for: language))
                                    .frame(width: 12, height: 12)
                                
                                Text(language)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        onOpenRepository(repository)
                    } label: {
                        Label("Ver en GitHub", systemImage: "safari")
                    }
                    .buttonStyle(.bordered)
                }
                
                if let description = repository.description, !description.isEmpty {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                
                HStack(spacing: 30) {
                    iPadOSStatView(count: repository.stargazersCount, title: "Stars", icon: "star.fill")
                    iPadOSStatView(count: repository.forksCount, title: "Forks", icon: "tuningfork")
                    iPadOSStatView(count: repository.watchersCount, title: "Watchers", icon: "eye.fill")
                }
                .padding(.vertical)
                
                if !repository.topics.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Temas")
                            .font(.headline)
                        
                        FlowLayout(items: repository.topics) { topic in
                            Text(topic)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    iPadOSRepositoryDetailView(
        repository: Repository.mock(),
        onOpenRepository: { _ in }
    )
}
#endif 