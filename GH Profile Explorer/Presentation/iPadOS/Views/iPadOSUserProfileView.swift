#if os(iOS)
import SwiftUI

struct iPadOSUserProfileView: View {
    private enum Constants {
        enum Layout {
            static let largeScreenWidth = 1000.0
            static let mediumScreenWidth = 600.0
        }
        
        enum Strings {
            static let loading = "loading_profile".localized
            static let errorTitle = "error".localized
            static let unknownError = "unknown_error".localized
            static let okButton = "ok".localized
        }
    }
    
    @StateObject var viewModel: iPadOSUserProfileViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.openURL) private var openURL
    @State private var showError = false
    @State private var error: AppError?
    @State private var columnVisibility: NavigationSplitViewVisibility = .detailOnly
    
    var body: some View {
        GeometryReader { geometry in
            NavigationSplitView(columnVisibility: $columnVisibility) {
                iPadOSSidebarView(
                    username: $viewModel.username,
                    searchHistory: viewModel.searchHistory,
                    currentUser: viewModel.userUI,
                    onSearch: {
                        viewModel.fetchUserProfile()
                        columnVisibility = .detailOnly
                    },
                    onSelectFromHistory: { username in
                        viewModel.selectFromHistory(username)
                        columnVisibility = .detailOnly
                    },
                    onClearHistory: viewModel.clearSearchHistory,
                    onRemoveFromHistory: viewModel.removeFromHistory,
                    onOpenInSafari: viewModel.openInSafari
                )
            } detail: {
                ZStack {
                    if case .loaded = viewModel.state, let user = viewModel.userUI {
                        if isCompactWidth(geometry) {
                            iPadOSCompactDetailView(
                                user: user,
                                repositories: viewModel.filteredRepositories,
                                geometry: geometry,
                                onOpenInSafari: viewModel.openInSafari,
                                onSelectRepository: { repo in
                                    viewModel.selectedRepository = repo
                                    if horizontalSizeClass == .compact {
                                        columnVisibility = .detailOnly
                                    }
                                }
                            )
                        } else {
                            iPadOSRegularDetailView(
                                user: user,
                                filteredRepositories: viewModel.filteredRepositories,
                                selectedRepository: viewModel.selectedRepository,
                                isDetailExpanded: viewModel.isDetailExpanded,
                                searchQuery: $viewModel.searchQuery,
                                geometry: geometry,
                                onToggleExpand: { viewModel.isDetailExpanded.toggle() },
                                onOpenInSafari: viewModel.openInSafari,
                                onShowQRCode: { viewModel.showUserQRCode = true },
                                onSelectRepository: { repo in viewModel.selectedRepository = repo },
                                onOpenRepository: viewModel.openRepositoryInSafari,
                                onClearSelection: { viewModel.selectedRepository = nil }
                            )
                        }
                    } else if case .loading = viewModel.state {
                        LoadingView(message: Constants.Strings.loading, isFullScreen: true)
                    } else if case let .error(appError) = viewModel.state {
                        ErrorView(error: appError, retryAction: viewModel.fetchUserProfile)
                    } else {
                        iPadOSEmptyStateView(onStartSearch: { columnVisibility = .all })
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationSplitViewStyle(.prominentDetail)
            .onAppear {
                updateOrientation(geometry: geometry)
                columnVisibility = .detailOnly
            }
            .onChange(of: viewModel.state) { oldValue, newValue in
                if case let .error(newError) = newValue {
                    error = newError
                    showError = true
                }
                
                if case .loaded = newValue {
                    columnVisibility = .detailOnly
                }
            }
            .onChange(of: geometry.size) { oldValue, newValue in
                updateOrientation(geometry: geometry)
            }
            .onChange(of: viewModel.urlToOpen) { oldValue, newValue in
                if let url = newValue {
                    openURL(url)
                    viewModel.urlToOpen = nil
                }
            }
            .alert(isPresented: $showError) {
                Alert(
                    title: Text(Constants.Strings.errorTitle),
                    message: Text(error?.localizedDescription ?? Constants.Strings.unknownError),
                    dismissButton: .default(Text(Constants.Strings.okButton))
                )
            }
            .sheet(isPresented: $viewModel.showUserQRCode) {
                if let user = viewModel.userUI {
                    iPadOSQRCodeSheetView(
                        user: user,
                        onClose: { viewModel.showUserQRCode = false }
                    )
                }
            }
        }
    }
    
    private func updateOrientation(geometry: GeometryProxy) {
        let orientation: DeviceOrientation = geometry.size.width > geometry.size.height ? .landscape : .portrait
        viewModel.updateOrientation(orientation)
    }
    
    private func isCompactWidth(_ geometry: GeometryProxy) -> Bool {
        return horizontalSizeClass == .compact || geometry.size.width < Constants.Layout.mediumScreenWidth
    }
}

#Preview {
    let networkClient = NetworkClient()
    let userRepository = UserRepository(networkClient: networkClient)
    let fetchUserUseCase = FetchUserUseCase(repository: userRepository)
    let fetchRepositoriesUseCase = FetchUserRepositoriesUseCase(repository: userRepository)
    let viewModel = iPadOSUserProfileViewModel(
        fetchUserUseCase: fetchUserUseCase,
        fetchRepositoriesUseCase: fetchRepositoriesUseCase
    )
    
    viewModel.state = .loaded(User.mock(), Repository.mockArray())
    
    return iPadOSUserProfileView(viewModel: viewModel)
}

#endif 