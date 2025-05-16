#if os(visionOS)
import SwiftUI
import RealityKit

// PreferenceKey para detectar el desplazamiento del scroll
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// Constantes globales utilizadas en la vista principal
private enum Constants {
    enum Strings {
        static let repositories = "repositories"
        static let loadingProfile = "loading_profile"
        static let searchForUsers = "search_for_users"
        static let enterUsername = "enter_username"
        static let viewRecentSearches = "view_recent_searches"
    }
    
    enum Layout {
        static let contentPadding: CGFloat = 24
        static let sectionSpacing: CGFloat = 20
    }
    
    enum Colors {
        static let background = Color.clear
    }
    
    enum Images {
        static let person = "person.fill.questionmark"
    }
}

struct VisionOSUserProfileView: View {
    @StateObject var viewModel: VisionOSUserProfileViewModel
    @State private var searchText = ""
    @State private var showSearchBar = true
    @Environment(\.openURL) private var openURLAction
    
    var body: some View {
        ZStack {
            Constants.Colors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Search bar (condicional)
                if showSearchBar {
                    VisionOSSearchBarSectionView(
                        username: $viewModel.username,
                        onSearch: viewModel.fetchUserProfile,
                        onShowHistory: { viewModel.isShowingSearchHistory = true }
                    )
                }
                
                // Main content
                ScrollView {
                    VStack(spacing: Constants.Layout.sectionSpacing) {
                        if let user = viewModel.userUI {
                            // Profile header
                            VisionOSProfileHeaderView(
                                user: user,
                                onOpenGitHubProfile: viewModel.openUserInGitHub
                            )
                            
                            // Repositories title
                            Text(Constants.Strings.repositories.localized)
                                .font(.title.bold())
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Repositories grid
                            VisionOSRepositoriesSectionView(
                                repositories: viewModel.repositoriesUI,
                                searchText: $searchText,
                                onRepositoryTap: viewModel.openRepositoryInBrowser
                            )
                        } else if case .error = viewModel.state {
                            errorView
                        } else if case .loading = viewModel.state {
                            loadingView
                        } else {
                            emptyView
                        }
                    }
                    .padding(Constants.Layout.contentPadding)
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                    withAnimation {
                        showSearchBar = offset <= 5
                    }
                }
            }
        }
        .onChange(of: searchText) { _, newValue in
            viewModel.setSearchQuery(newValue)
        }
        .onChange(of: viewModel.urlToOpen) { _, url in
            if let url = url {
                openURLAction(url)
            }
        }
        .sheet(isPresented: $viewModel.isShowingSearchHistory) {
            VisionOSSearchHistoryView(
                searchHistory: viewModel.searchHistory,
                isShowing: $viewModel.isShowingSearchHistory,
                onSelect: { username in
                    viewModel.username = username
                    viewModel.fetchUserProfile()
                },
                onClearAll: viewModel.clearSearchHistory,
                onRemoveItem: viewModel.removeSearchHistoryItem
            )
        }
    }
    
    // MARK: - View Components
    
    private var loadingView: some View {
        VisionOSLoadingView(message: Constants.Strings.loadingProfile.localized)
    }
    
    private var errorView: some View {
        if case let .error(error) = viewModel.state {
            return AnyView(
                VisionOSErrorView(error: error) {
                    viewModel.fetchUserProfile()
                }
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    private var emptyView: some View {
        VisionOSEmptyStateView(
            icon: Constants.Images.person,
            title: Constants.Strings.searchForUsers.localized,
            message: Constants.Strings.enterUsername.localized,
            action: {
                viewModel.isShowingSearchHistory = true
            },
            actionLabel: Constants.Strings.viewRecentSearches.localized
        )
    }
}

#Preview {
    let viewModel = VisionOSUserProfileViewModel(
        manageSearchHistoryUseCase: nil, 
        filterRepositoriesUseCase: nil, 
        openURLUseCase: nil
    )
    
    // Configuramos un estado con datos mock
    let user = User.mock()
    let repositories = [Repository.mock(), Repository.mock()]
    viewModel.state = VisionOSViewState.loaded(user, repositories)
    
    return VisionOSUserProfileView(viewModel: viewModel)
}

#endif 
