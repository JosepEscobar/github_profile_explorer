#if os(iOS)
import SwiftUI

struct iPadOSUserProfileView: View {
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
                    currentUser: viewModel.currentUser,
                    onSearch: viewModel.fetchUserProfile,
                    onSelectFromHistory: viewModel.selectFromHistory,
                    onClearHistory: viewModel.clearSearchHistory,
                    onRemoveFromHistory: viewModel.removeFromHistory,
                    onOpenInSafari: viewModel.openInSafari
                )
            } detail: {
                if case let .loaded(user, repositories) = viewModel.state {
                    detailContent(user: user, repositories: repositories, geometry: geometry)
                } else if case .loading = viewModel.state {
                    LoadingView(message: "Cargando perfil...", isFullScreen: true)
                } else if case let .error(appError) = viewModel.state {
                    ErrorView(error: appError, retryAction: viewModel.fetchUserProfile)
                } else {
                    ContentUnavailableView {
                        Label("Busca un usuario de GitHub", systemImage: "magnifyingglass")
                    } description: {
                        Text("Ingresa un nombre de usuario en la barra lateral para ver su perfil.")
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
                    if geometry.size.width > 1000 {
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
                    if newValue.width > 1000 {
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
                    title: Text("Error"),
                    message: Text(error?.localizedDescription ?? "Ha ocurrido un error desconocido"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $viewModel.showUserQRCode) {
                if case let .loaded(user, _) = viewModel.state {
                    VStack(spacing: 20) {
                        Text("Escanea para ver el perfil")
                            .font(.headline)
                        
                        Image(systemName: "qrcode")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                        
                        Text("github.com/\(user.login)")
                            .font(.caption)
                        
                        Button("Cerrar") {
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
    private func detailContent(user: User, repositories: [Repository], geometry: GeometryProxy) -> some View {
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
                            min(detailGeometry.size.width * 0.5, 600) : 
                            min(detailGeometry.size.width * 0.4, 500)
                    )
                    .background(Color.primary.opacity(0.03))
                    
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
        return horizontalSizeClass == .compact || geometry.size.width < 600
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
