#if os(iOS)
import SwiftUI

struct iPadOSRepositoryListView: View {
    private enum Constants {
        enum Layout {
            static let itemSpacing: CGFloat = 16
            static let itemVerticalPadding: CGFloat = 8
            static let cornerRadius: CGFloat = 8
        }
        
        enum Colors {
            static let background = Color.primary.opacity(0.05)
            static let shadow = Color.black.opacity(0.05)
        }
        
        enum Images {
            static let emptyState = "magnifyingglass"
        }
        
        enum Strings {
            static let emptyRepositories = "no_repositories".localized
        }
    }
    
    let repositories: [RepositoryUIModel]
    var onSelectRepository: (RepositoryUIModel) -> Void
    
    var body: some View {
        if repositories.isEmpty {
            ContentUnavailableView(Constants.Strings.emptyRepositories, systemImage: Constants.Images.emptyState)
                .frame(maxWidth: .infinity)
        } else {
            ScrollView {
                VStack(spacing: Constants.Layout.itemSpacing) {
                    ForEach(repositories) { repository in
                        iPadOSRepositoryItemView(repository: repository) { selectedRepo in
                            onSelectRepository(selectedRepo)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, Constants.Layout.itemVerticalPadding)
                        .background(Constants.Colors.background)
                        .cornerRadius(Constants.Layout.cornerRadius)
                        .shadow(color: Constants.Colors.shadow, radius: 3)
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    iPadOSRepositoryListView(
        repositories: RepositoryUIModel.mockArray(),
        onSelectRepository: { _ in }
    )
}
#endif 