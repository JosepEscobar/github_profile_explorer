#if os(visionOS)
import SwiftUI
import RealityKit
import Kingfisher

struct VisionOSUserProfileView: View {
    private enum Constants {
        enum Strings {
            static let search = "search"
            static let searchUser = "search_user"
            static let noRepositoriesFound = "no_repositories_found"
            static let tryDifferentSearch = "try_different_search"
            static let searchRepositories = "search_repositories"
            static let repositories = "repositories"
            static let toggleImmersive = "toggle_immersive_view"
            static let closeImmersive = "close_immersive_view"
            static let recentSearches = "recent_searches"
            static let clearAll = "clear_all"
            static let cancel = "cancel"
            static let loadingProfile = "loading_profile"
            static let searchForUsers = "search_for_users"
            static let enterUsername = "enter_username"
            static let viewRecentSearches = "view_recent_searches"
        }
        
        enum Layout {
            static let contentPadding: CGFloat = 24
            static let sectionSpacing: CGFloat = 20
            static let gridSpacing: CGFloat = 20
        }
        
        enum Colors {
            static let background = Color.clear
        }
        
        enum Images {
            static let search = "magnifyingglass"
            static let vr = "visionpro"
            static let close = "xmark"
            static let clock = "clock"
            static let person = "person.fill.questionmark"
        }
    }
    
    @StateObject var viewModel: VisionOSUserProfileViewModel
    @State private var searchText = ""
    @State private var selectedLanguageFilter: String? = nil
    @State private var isImmersiveViewActive = false
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    var body: some View {
        ZStack {
            Constants.Colors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Search bar
                searchBarSection
                
                // Main content
                ScrollView {
                    VStack(spacing: Constants.Layout.sectionSpacing) {
                        if let user = viewModel.userUI {
                            // Profile header
                            VisionOSProfileHeaderView(
                                user: user,
                                onOpenGitHubProfile: viewModel.openUserInGitHub
                            )
                            
                            // Language filters
                            languageFilters
                            
                            // Immersive mode toggle
                            immersiveToggle
                            
                            // Repositories grid
                            repositoriesSection
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
            }
        }
        .task {
            viewModel.configureImmersiveSpaceUpdates()
        }
        .onChange(of: searchText) { _, newValue in
            viewModel.setSearchQuery(newValue)
        }
        .onChange(of: selectedLanguageFilter) { _, newValue in
            viewModel.setLanguageFilter(newValue)
        }
        .onChange(of: viewModel.isInImmersiveSpace) { _, isActive in
            isImmersiveViewActive = isActive
        }
        .onChange(of: viewModel.urlToOpen) { _, url in
            if let url = url {
                openURL(url)
            }
        }
        .sheet(isPresented: $viewModel.isShowingSearchHistory) {
            searchHistoryView
        }
        .onChange(of: viewModel.isInImmersiveSpace) { _, isActive in
            if isActive {
                Task {
                    _ = await openImmersiveSpace(id: ImmersiveSpaceRegistration.immersiveSpaceID)
                }
            } else {
                Task {
                    await dismissImmersiveSpace()
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var searchBarSection: some View {
        HStack {
            Button {
                viewModel.isShowingSearchHistory = true
            } label: {
                Image(systemName: Constants.Images.search)
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            
            VisionOSSearchBarView(
                text: $viewModel.username,
                placeholder: Constants.Strings.searchUser.localized
            ) {
                viewModel.fetchUserProfile()
            }
            
            Button {
                viewModel.fetchUserProfile()
            } label: {
                Text(Constants.Strings.search.localized)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .keyboardShortcut(.defaultAction)
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    private var languageFilters: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Constants.Strings.repositories.localized)
                .font(.title.bold())
                .padding(.horizontal)
            
            VisionOSLanguageFilterView(
                languages: viewModel.uniqueLanguages,
                selectedLanguage: $selectedLanguageFilter
            )
        }
    }
    
    private var immersiveToggle: some View {
        HStack {
            Button {
                viewModel.toggleImmersiveMode()
            } label: {
                Label(
                    isImmersiveViewActive ? 
                        Constants.Strings.closeImmersive.localized : 
                        Constants.Strings.toggleImmersive.localized,
                    systemImage: isImmersiveViewActive ? Constants.Images.close : Constants.Images.vr
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.blue)
        }
        .padding(.horizontal)
    }
    
    private var repositoriesSection: some View {
        VStack(alignment: .leading, spacing: Constants.Layout.sectionSpacing) {
            // Search bar for repositories
            VisionOSSearchBarView(
                text: $searchText,
                placeholder: Constants.Strings.searchRepositories.localized
            )
            .padding(.horizontal)
            
            // Repositories grid or empty state
            if viewModel.filteredRepositoriesUI.isEmpty {
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
                    ForEach(viewModel.filteredRepositoriesUI) { repository in
                        VisionOSRepositoryCardView(repository: repository)
                            .onTapGesture {
                                viewModel.openRepositoryInBrowser(repository)
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var searchHistoryView: some View {
        NavigationStack {
            List {
                ForEach(viewModel.searchHistory, id: \.self) { item in
                    Button {
                        viewModel.username = item
                        viewModel.isShowingSearchHistory = false
                        viewModel.fetchUserProfile()
                    } label: {
                        HStack {
                            Image(systemName: Constants.Images.clock)
                                .foregroundColor(.secondary)
                            Text(item)
                                .foregroundColor(.primary)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        if index < viewModel.searchHistory.count {
                            viewModel.removeSearchHistoryItem(at: index)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(Constants.Strings.recentSearches.localized)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.clearSearchHistory()
                    } label: {
                        Text(Constants.Strings.clearAll.localized)
                    }
                    .disabled(viewModel.searchHistory.isEmpty)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        viewModel.isShowingSearchHistory = false
                    } label: {
                        Text(Constants.Strings.cancel.localized)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
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

// Extensión para obtener cadenas localizadas
private extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}

#Preview {
    let viewModel = VisionOSUserProfileViewModel(manageSearchHistoryUseCase: nil, filterRepositoriesUseCase: nil, openURLUseCase: nil)
    viewModel.userUI = UserUIModel.mock()
    viewModel.repositoriesUI = [RepositoryUIModel.mock(), RepositoryUIModel.mock()]
    
    return VisionOSUserProfileView(viewModel: viewModel)
}
#endif 