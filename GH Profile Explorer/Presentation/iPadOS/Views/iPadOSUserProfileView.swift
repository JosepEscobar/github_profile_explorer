#if os(iOS)
import SwiftUI

struct iPadOSUserProfileView: View {
    private enum Constants {
        enum Layout {
            static let largeScreenWidth = 1000.0
            static let mediumScreenWidth = 600.0
            static let detailWidthRatioExpanded = 0.5
            static let detailWidthRatioCollapsed = 0.4
            static let detailWidthMaxExpanded = 600.0
            static let detailWidthMaxCollapsed = 500.0
            static let repositoriesHeightRatio = 0.6
        }
        
        enum Strings {
            static let loading = "loading_profile".localized
            static let searchPrompt = "search_prompt".localized
            static let searchDescription = "search_description".localized
            static let scanQRTitle = "scan_qr_title".localized
            static let githubPrefix = "github.com/"
            static let closeButton = "close".localized
            static let errorTitle = "error".localized
            static let unknownError = "unknown_error".localized
            static let okButton = "ok".localized
        }
        
        enum Images {
            static let search = "magnifyingglass"
            static let qrCode = "qrcode"
        }
        
        enum Colors {
            static let background = Color.primary.opacity(0.03)
            static let shadow = Color.black.opacity(0.1)
        }
    }
    
    @StateObject var viewModel: iPadOSUserProfileViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.openURL) private var openURL
    @State private var showError = false
    @State private var error: AppError?
    @State private var columnVisibility: NavigationSplitViewVisibility = .automatic
    
    var body: some View {
        GeometryReader { geometry in
            NavigationSplitView(columnVisibility: $columnVisibility) {
                iPadOSSidebarView(
                    username: $viewModel.username,
                    searchHistory: viewModel.searchHistory,
                    currentUser: viewModel.userUI,
                    onSearch: viewModel.fetchUserProfile,
                    onSelectFromHistory: viewModel.selectFromHistory,
                    onClearHistory: viewModel.clearSearchHistory,
                    onRemoveFromHistory: viewModel.removeFromHistory,
                    onOpenInSafari: viewModel.openInSafari
                )
            } detail: {
                if case .loaded = viewModel.state, let user = viewModel.userUI {
                    detailContent(user: user, repositories: viewModel.repositoriesUI, geometry: geometry)
                } else if case .loading = viewModel.state {
                    LoadingView(message: Constants.Strings.loading, isFullScreen: true)
                } else if case let .error(appError) = viewModel.state {
                    ErrorView(error: appError, retryAction: viewModel.fetchUserProfile)
                } else {
                    ContentUnavailableView {
                        Label(Constants.Strings.searchPrompt, systemImage: Constants.Images.search)
                    } description: {
                        Text(Constants.Strings.searchDescription)
                    }
                    .onAppear {
                        columnVisibility = .all // Asegura que la barra lateral esté visible cuando no hay resultados
                    }
                }
            }
            .navigationSplitViewStyle(.balanced)
            .onAppear {
                updateOrientation(geometry: geometry)
                // Si no hay resultados, mostrar la barra lateral por defecto
                if case .loaded = viewModel.state {
                    // Mantener la configuración actual si hay contenido
                } else {
                    columnVisibility = .all
                }
            }
            .onChange(of: viewModel.state) { oldValue, newValue in
                if case let .error(newError) = newValue {
                    error = newError
                    showError = true
                }
                
                // Actualizar visibilidad cuando cambia el estado
                if case .loaded = newValue {
                    if geometry.size.width > Constants.Layout.largeScreenWidth {
                        // En pantallas grandes, mostrar ambas columnas
                        columnVisibility = .all
                    } else {
                        // En pantallas más pequeñas, ocultar la barra lateral cuando hay resultados
                        columnVisibility = .detailOnly
                    }
                } else {
                    // Cuando no hay resultados, mostrar la barra lateral
                    columnVisibility = .all
                }
            }
            .onChange(of: geometry.size) { oldValue, newValue in
                updateOrientation(geometry: geometry)
                
                // Ajustar visibilidad cuando cambia el tamaño de la pantalla
                if case .loaded = viewModel.state {
                    if newValue.width > Constants.Layout.largeScreenWidth {
                        columnVisibility = .all
                    }
                }
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
                    VStack(spacing: 20) {
                        Text(Constants.Strings.scanQRTitle)
                            .font(.headline)
                        
                        Image(systemName: Constants.Images.qrCode)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                        
                        Text(Constants.Strings.githubPrefix + user.login)
                            .font(.caption)
                        
                        Button(Constants.Strings.closeButton) {
                            viewModel.showUserQRCode = false
                        }
                        .buttonStyle(.bordered)
                        .padding(.top)
                    }
                    .padding()
                }
            }
        }
    }
    
    private func updateOrientation(geometry: GeometryProxy) {
        let orientation: DeviceOrientation = geometry.size.width > geometry.size.height ? .landscape : .portrait
        viewModel.updateOrientation(orientation)
    }
    
    @ViewBuilder
    private func detailContent(user: UserUIModel, repositories: [RepositoryUIModel], geometry: GeometryProxy) -> some View {
        if isCompactWidth(geometry) {
            // Compact (portrait) - stack content vertically
            ScrollView {
                VStack(spacing: 20) {
                    iPadOSProfileHeaderView(
                        user: user,
                        onOpenInSafari: viewModel.openInSafari
                    )
                    
                    iPadOSRepositoryListView(
                        repositories: viewModel.filteredRepositories,
                        onSelectRepository: { repo in
                            viewModel.selectedRepository = repo
                            if horizontalSizeClass == .compact {
                                columnVisibility = .detailOnly
                            }
                        }
                    )
                    .frame(height: geometry.size.height * Constants.Layout.repositoriesHeightRatio)
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
        } else {
            // Regular (landscape) - use horizontal layout with flexible sizing
            GeometryReader { detailGeometry in
                HStack(spacing: 0) {
                    // Perfil (izquierda)
                    ScrollView {
                        iPadOSProfileDetailView(
                            user: user,
                            isDetailExpanded: viewModel.isDetailExpanded,
                            onToggleExpand: { viewModel.isDetailExpanded.toggle() },
                            onOpenInSafari: viewModel.openInSafari,
                            onShowQRCode: { viewModel.showUserQRCode = true }
                        )
                    }
                    .frame(
                        width: viewModel.isDetailExpanded ? 
                            min(detailGeometry.size.width * Constants.Layout.detailWidthRatioExpanded, Constants.Layout.detailWidthMaxExpanded) : 
                            min(detailGeometry.size.width * Constants.Layout.detailWidthRatioCollapsed, Constants.Layout.detailWidthMaxCollapsed)
                    )
                    .background(Constants.Colors.background)
                    
                    Divider()
                    
                    // Repositorios (derecha)
                    VStack(spacing: 0) {
                        iPadOSRepositorySearchView(
                            searchQuery: $viewModel.searchQuery,
                            isRepositorySelected: viewModel.selectedRepository != nil,
                            onClearSelection: { viewModel.selectedRepository = nil }
                        )
                        
                        if let repository = viewModel.selectedRepository {
                            iPadOSRepositoryDetailView(
                                repository: repository,
                                onOpenRepository: viewModel.openRepositoryInSafari
                            )
                        } else {
                            iPadOSRepositoryListView(
                                repositories: viewModel.filteredRepositories,
                                onSelectRepository: { repo in
                                    viewModel.selectedRepository = repo
                                }
                            )
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
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
