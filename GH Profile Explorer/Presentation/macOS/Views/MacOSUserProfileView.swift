#if os(macOS)
import SwiftUI
import Charts

struct MacOSUserProfileView: View {
    private enum Constants {
        enum Layout {
            static let minWidth: CGFloat = 800
            static let minHeight: CGFloat = 500
        }
        
        enum Strings {
            static let error = "error".localized
            static let unknownError = "unknown_error".localized
            static let ok = "ok".localized
            static let addToFavorites = "add_to_favorites".localized
            static let openInBrowser = "open_in_browser".localized
        }
        
        enum Images {
            static let star = "star"
            static let starFill = "star.fill"
            static let safari = "safari"
        }
        
        enum Colors {
            static let starColor = Color.yellow
            static let primaryColor = Color.primary
        }
    }
    
    @StateObject var viewModel: macOSUserProfileViewModel
    @Environment(\.openURL) private var openURL
    @State private var selectedSidebarItem: MacOSSidebarItem = .search
    @State private var showError: Bool = false
    @State private var error: AppError?
    @State private var localSelectedRepository: RepositoryUIModel? = nil
    
    var body: some View {
        NavigationSplitView {
            MacOSSidebarView(viewModel: viewModel, selectedSidebarItem: $selectedSidebarItem)
        } detail: {
            detailView
        }
        .onChange(of: viewModel.state) { oldState, newState in
            if case let .error(newError) = newState {
                error = newError
                showError = true
            }
            
            if case let .loaded(user, repositories) = newState {
                viewModel.handleLoadedState(user: user, repositories: repositories)
                
                if selectedSidebarItem == .search {
                    selectedSidebarItem = .profile
                }
            }
        }
        .onChange(of: viewModel.urlToOpen) { oldValue, newValue in
            if let url = newValue {
                openURL(url)
                viewModel.urlToOpen = nil
            }
        }
        .onChange(of: localSelectedRepository) { oldValue, newValue in
            if oldValue != newValue {
                DispatchQueue.main.async {
                    viewModel.selectedRepository = newValue
                }
            }
        }
        .onChange(of: viewModel.selectedRepository) { oldValue, newValue in
            if oldValue != newValue && localSelectedRepository != newValue {
                localSelectedRepository = newValue
            }
        }
        .onAppear {
            localSelectedRepository = viewModel.selectedRepository
        }
        .alert(isPresented: $showError) {
            Alert(
                title: Text(Constants.Strings.error),
                message: Text(error?.localizedDescription ?? Constants.Strings.unknownError),
                dismissButton: .default(Text(Constants.Strings.ok))
            )
        }
        .frame(minWidth: Constants.Layout.minWidth, minHeight: Constants.Layout.minHeight)
        .toolbar {
            ToolbarItem {
                Button {
                    if let user = viewModel.userUI {
                        viewModel.toggleFavorite(username: user.login)
                    }
                } label: {
                    if let user = viewModel.userUI {
                        Image(systemName: viewModel.isFavorite(username: user.login) ? Constants.Images.starFill : Constants.Images.star)
                            .foregroundColor(viewModel.isFavorite(username: user.login) ? Constants.Colors.starColor : Constants.Colors.primaryColor)
                    } else {
                        Image(systemName: Constants.Images.star)
                            .foregroundColor(Constants.Colors.primaryColor)
                    }
                }
                .disabled(viewModel.userUI == nil)
                .help(Constants.Strings.addToFavorites)
            }
            
            ToolbarItem {
                Button {
                    if let user = viewModel.userUI {
                        viewModel.openInBrowser(username: user.login)
                    }
                } label: {
                    Image(systemName: Constants.Images.safari)
                }
                .disabled(viewModel.userUI == nil)
                .help(Constants.Strings.openInBrowser)
            }
        }
    }
    
    private var isUserLoaded: Bool {
        return viewModel.userUI != nil
    }
    
    @ViewBuilder
    private var detailView: some View {
        switch viewModel.state {
        case .idle:
            MacOSEmptyStateView()
            
        case .loading:
            LoadingView(message: "loading_profile".localized, isFullScreen: true)
            
        case .loaded where selectedSidebarItem == .profile:
            if let user = viewModel.userUI {
                MacOSUserDetailView(user: user, onOpenInSafari: viewModel.openInBrowser)
            }
            
        case .loaded where selectedSidebarItem == .repositories:
            MacOSRepositoriesListView(
                repositories: viewModel.filteredRepositories,
                searchQuery: $viewModel.searchQuery,
                selectedRepository: $localSelectedRepository,
                onOpenRepository: viewModel.openRepositoryInBrowser
            )
            
        case .loaded where selectedSidebarItem == .stats:
            MacOSLanguageStatsView(languageStats: viewModel.languageStats)
            
        case .error(let appError):
            ErrorView(error: appError, retryAction: viewModel.fetchUserProfile)
            
        default:
            ContentUnavailableView("select_option".localized, systemImage: "sidebar.left")
        }
    }
}

#Preview {
    let networkClient = NetworkClient()
    let userRepository = UserRepository(networkClient: networkClient)
    let fetchUserUseCase = FetchUserUseCase(repository: userRepository)
    let fetchRepositoriesUseCase = FetchUserRepositoriesUseCase(repository: userRepository)
    let viewModel = macOSUserProfileViewModel(
        fetchUserUseCase: fetchUserUseCase,
        fetchRepositoriesUseCase: fetchRepositoriesUseCase
    )
    
    return MacOSUserProfileView(viewModel: viewModel)
}
#endif 