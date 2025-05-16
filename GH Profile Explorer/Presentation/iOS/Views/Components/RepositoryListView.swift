#if os(iOS)
import SwiftUI

struct RepositoryListView: View {
    let repositories: [RepositoryUIModel]
    
    private enum Constants {
        enum Images {
            static let emptyState = "magnifyingglass"
        }
        
        enum Keys {
            static let noRepositories = "no_repositories"
            static let searchSuggestion = "search_suggestion"
        }
        
        enum Layout {
            static let emptyStateSpacing: CGFloat = 16
            static let emptyStateIconSize: CGFloat = 40
            static let emptyStateVerticalPadding: CGFloat = 40
            static let repositoriesSpacing: CGFloat = 1
            static let itemVerticalPadding: CGFloat = 4
            static let dividerLeadingPadding: CGFloat = 24
            static let cornerRadius: CGFloat = 12
            static let shadowRadius: CGFloat = 5
        }
        
        enum Colors {
            static let background = Color.primary.opacity(0.05)
            static let shadow = Color.black.opacity(0.05)
        }
    }
    
    var body: some View {
        if repositories.isEmpty {
            emptyStateView
        } else {
            repositoriesListView
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: Constants.Layout.emptyStateSpacing) {
            Image(systemName: Constants.Images.emptyState)
                .font(.system(size: Constants.Layout.emptyStateIconSize))
                .foregroundColor(.secondary)
            
            Text(Constants.Keys.noRepositories.localized)
                .font(.headline)
            
            Text(Constants.Keys.searchSuggestion.localized)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Constants.Layout.emptyStateVerticalPadding)
    }
    
    private var repositoriesListView: some View {
        VStack(spacing: Constants.Layout.repositoriesSpacing) {
            ForEach(repositories) { repository in
                RepositoryItemUIView(repository: repository)
                    .padding(.vertical, Constants.Layout.itemVerticalPadding)
                    .padding(.horizontal)
                    .background(Constants.Colors.background)
                
                if repository.id != repositories.last?.id {
                    Divider()
                        .padding(.leading, Constants.Layout.dividerLeadingPadding)
                }
            }
        }
        .background(Constants.Colors.background)
        .cornerRadius(Constants.Layout.cornerRadius)
        .shadow(color: Constants.Colors.shadow, radius: Constants.Layout.shadowRadius)
    }
}

#Preview {
    Group {
        RepositoryListView(repositories: RepositoryUIModel.mockArray())
            .padding()
        
        RepositoryListView(repositories: [])
            .padding()
    }
}
#endif 
