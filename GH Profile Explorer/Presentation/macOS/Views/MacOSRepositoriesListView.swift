#if os(macOS)
import SwiftUI

struct MacOSRepositoriesListView: View {
    private enum Constants {
        enum Layout {
            static let spacing: CGFloat = 16
        }
        
        enum Strings {
            static let searchRepositories = "search_repositories".localized
            static let noRepositoriesFound = "no_repositories_found".localized
            static let open = "open".localized
        }
        
        enum Images {
            static let search = "magnifyingglass"
            static let clear = "xmark.circle.fill"
            static let noResults = "magnifyingglass"
            static let open = "arrow.up.right.square"
        }
        
        enum Colors {
            static let searchBackground = Color.secondary.opacity(0.1)
            static let iconSecondary = Color.secondary
        }
    }
    
    let repositories: [RepositoryUIModel]
    @Binding var searchQuery: String
    @Binding var selectedRepository: RepositoryUIModel?
    let onOpenRepository: (RepositoryUIModel) -> Void
    
    private var filteredRepositories: [RepositoryUIModel] {
        guard !searchQuery.isEmpty else { return repositories }
        return repositories.filter { repo in
            repo.name.localizedCaseInsensitiveContains(searchQuery) ||
            (repo.description?.localizedCaseInsensitiveContains(searchQuery) ?? false)
        }
    }
    
    var body: some View {
        VStack {
            // Campo de búsqueda
            HStack {
                Image(systemName: Constants.Images.search)
                    .foregroundColor(Constants.Colors.iconSecondary)
                
                TextField(Constants.Strings.searchRepositories, text: $searchQuery)
                    .textFieldStyle(.plain)
                
                if !searchQuery.isEmpty {
                    Button {
                        searchQuery = ""
                    } label: {
                        Image(systemName: Constants.Images.clear)
                            .foregroundColor(Constants.Colors.iconSecondary)
                    }
                    .buttonStyle(.borderless)
                }
            }
            .padding()
            .background(Constants.Colors.searchBackground)
            .cornerRadius(8)
            .padding([.horizontal, .top])
            
            // Lista de repositorios
            if filteredRepositories.isEmpty {
                ContentUnavailableView(
                    Constants.Strings.noRepositoriesFound, 
                    systemImage: Constants.Images.noResults
                )
            } else {
                List(selection: $selectedRepository) {
                    ForEach(filteredRepositories) { repository in
                        MacOSRepositoryItemView(repository: repository)
                            .tag(repository)
                    }
                }
                .listStyle(.inset)
            }
        }
        .safeAreaInset(edge: .bottom) {
            if let selected = selectedRepository {
                HStack {
                    VStack(alignment: .leading) {
                        Text(selected.name)
                            .font(.headline)
                        if let description = selected.description {
                            Text(description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        onOpenRepository(selected)
                    } label: {
                        Label(Constants.Strings.open, systemImage: Constants.Images.open)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(.thinMaterial)
            }
        }
    }
}

struct MacOSRepositoryItemView: View {
    private enum Constants {
        enum Layout {
            static let spacing: CGFloat = 8
            static let circleSize: CGFloat = 12
            static let padding: CGFloat = 4
        }
    }
    
    let repository: RepositoryUIModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Layout.spacing) {
            HStack(alignment: .center) {
                Text(repository.name)
                    .font(.headline)
                
                Spacer()
                
                if let language = repository.language {
                    HStack(spacing: Constants.Layout.spacing) {
                        Circle()
                            .fill(LanguageColorUtils.color(for: language))
                            .frame(width: Constants.Layout.circleSize, height: Constants.Layout.circleSize)
                        
                        Text(language)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text("★ \(repository.stars)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let description = repository.description {
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(Constants.Layout.padding)
    }
}

#Preview {
    MacOSRepositoriesListView(
        repositories: RepositoryUIModel.mockArray(),
        searchQuery: .constant(""),
        selectedRepository: .constant(nil),
        onOpenRepository: { _ in }
    )
}

#endif 