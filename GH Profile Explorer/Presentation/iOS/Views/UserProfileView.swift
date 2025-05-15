#if os(iOS)
import SwiftUI

struct UserProfileView: View {
    let user: User
    let repositories: [Repository]
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var selectedLanguageFilter: String?
    @State private var searchText = ""
    
    private var filteredRepositories: [Repository] {
        var filtered = repositories
        
        // Apply text search if any
        if !searchText.isEmpty {
            filtered = filtered.filter { repo in
                repo.name.localizedCaseInsensitiveContains(searchText) ||
                (repo.description?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // Apply language filter if selected
        if let language = selectedLanguageFilter {
            filtered = filtered.filter { $0.language == language }
        }
        
        return filtered
    }
    
    private var languages: [String] {
        let allLanguages = repositories.compactMap { $0.language }
        return Array(Set(allLanguages)).sorted()
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // User profile header
                HStack(spacing: 16) {
                    AvatarImageView(url: user.avatarURL, size: 100, cornerRadius: 50)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.name ?? user.login)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("@\(user.login)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if let location = user.location {
                            Label(location, systemImage: "location")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 12) {
                            Label("\(user.followers)", systemImage: "person.2")
                                .font(.caption)
                            
                            Label("\(user.publicRepos)", systemImage: "book.closed")
                                .font(.caption)
                        }
                        .padding(.top, 4)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color.primary.opacity(0.05))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5)
                
                // Bio if available
                if let bio = user.bio, !bio.isEmpty {
                    Text(bio)
                        .font(.body)
                        .padding()
                        .background(Color.primary.opacity(0.05))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 5)
                }
                
                // Language filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Button {
                            selectedLanguageFilter = nil
                        } label: {
                            HStack {
                                Text("Todos")
                                if selectedLanguageFilter == nil {
                                    Image(systemName: "checkmark")
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedLanguageFilter == nil ? Color.blue : Color.secondary.opacity(0.1))
                            .foregroundColor(selectedLanguageFilter == nil ? .white : .primary)
                            .cornerRadius(8)
                        }
                        
                        ForEach(languages, id: \.self) { language in
                            Button {
                                selectedLanguageFilter = language
                            } label: {
                                HStack {
                                    Circle()
                                        .fill(languageColor(for: language))
                                        .frame(width: 8, height: 8)
                                    
                                    Text(language)
                                    
                                    if selectedLanguageFilter == language {
                                        Image(systemName: "checkmark")
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedLanguageFilter == language ? Color.blue : Color.secondary.opacity(0.1))
                                .foregroundColor(selectedLanguageFilter == language ? .white : .primary)
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.leading, 16)
                    .padding(.trailing, 16)
                }
                .padding(.horizontal, -16)
                
                // Search for repositories
                SearchBarView(
                    text: $searchText,
                    placeholder: "Buscar repositorios"
                )
                .padding(.top, 8)
                .padding(.bottom, 8)
                .padding(.leading, -16)
                
                // Repositories list
                if filteredRepositories.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        
                        Text("No se encontraron repositorios")
                            .font(.headline)
                        
                        Text("Intenta con otra búsqueda o filtro")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    VStack(spacing: 1) {
                        ForEach(filteredRepositories) { repository in
                            RepositoryItemView(repository: repository)
                                .padding(.vertical, 4)
                                .background(Color.primary.opacity(0.05))
                            
                            if repository.id != filteredRepositories.last?.id {
                                Divider()
                                    .padding(.leading, 24)
                            }
                        }
                    }
                    .background(Color.primary.opacity(0.05))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 5)
                }
            }
            .padding(16)
        }
        .background(Color.secondary.opacity(0.05))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .navigationTitle(user.login)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    AvatarImageView(url: user.avatarURL, size: 30, cornerRadius: 15)
                    Text(user.login)
                        .font(.headline)
                }
            }
            
            #if !os(macOS)
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if let url = URL(string: "https://github.com/\(user.login)") {
                        openURL(url)
                    }
                } label: {
                    Image(systemName: "safari")
                }
            }
            #endif
        }
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
    NavigationStack {
        UserProfileView(
            user: User.mock(),
            repositories: Repository.mockArray()
        )
    }
}
#endif 
