#if os(visionOS)
import SwiftUI

struct VisionOSRepositoriesSectionView: View {
    let repositories: [RepositoryUIModel]
    @Binding var searchText: String
    var onRepositoryTap: (RepositoryUIModel) -> Void
    
    private enum Constants {
        enum Strings {
            static let searchRepositories = "search_repositories"
            static let noRepositoriesFound = "no_repositories_found"
            static let tryDifferentSearch = "try_different_search"
        }
        
        enum Layout {
            static let contentPadding: CGFloat = 24
            static let sectionSpacing: CGFloat = 20
            static let gridSpacing: CGFloat = 20
        }
        
        enum Images {
            static let search = "magnifyingglass"
        }
    }
    
    var filteredRepositories: [RepositoryUIModel] {
        if searchText.isEmpty {
            return repositories
        } else {
            return repositories.filter { repository in
                repository.name.localizedCaseInsensitiveContains(searchText) ||
                repository.description?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Layout.sectionSpacing) {
            // Search bar for repositories
            VisionOSSearchBarView(
                text: $searchText,
                placeholder: Constants.Strings.searchRepositories.localized
            )
            .padding(.horizontal)
            .background(GeometryReader { proxy in
                Color.clear
                    .preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: proxy.frame(in: .named("scroll")).minY
                    )
            })
            
            // Repositories grid or empty state
            if filteredRepositories.isEmpty {
                VisionOSEmptyStateView(
                    icon: Constants.Images.search,
                    title: Constants.Strings.noRepositoriesFound.localized,
                    message: Constants.Strings.tryDifferentSearch.localized
                )
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 350), spacing: Constants.Layout.gridSpacing)
                    ],
                    spacing: Constants.Layout.gridSpacing
                ) {
                    ForEach(filteredRepositories) { repository in
                        VisionOSRepositoryCardView(repository: repository)
                            .onTapGesture {
                                onRepositoryTap(repository)
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    VisionOSRepositoriesSectionView(
        repositories: RepositoryUIModel.mockArray(),
        searchText: .constant(""),
        onRepositoryTap: { _ in }
    )
}
#endif 