import SwiftUI
import Charts

struct MacOSUserProfileView: View {
    @StateObject var viewModel: macOSUserProfileViewModel
    @Environment(\.openURL) private var openURL
    @State private var selectedSidebarItem: SidebarItem = .search
    @State private var showError: Bool = false
    @State private var error: AppError?
    
    var body: some View {
        NavigationSplitView {
            SidebarView(viewModel: viewModel, selectedSidebarItem: $selectedSidebarItem)
        } detail: {
            detailView
        }
        .onChange(of: viewModel.state) { oldState, newState in
            if case let .error(newError) = newState {
                error = newError
                showError = true
            }
            
            if case let .loaded(_, repositories) = newState {
                viewModel.calculateLanguageStats()
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
                dismissButton: .default(Text("Aceptar"))
            )
        }
        .frame(minWidth: 800, minHeight: 500)
        .toolbar {
            ToolbarItem {
                Button {
                    if case let .loaded(user, _) = viewModel.state {
                        viewModel.toggleFavorite(username: user.login)
                    }
                } label: {
                    if case let .loaded(user, _) = viewModel.state {
                        Image(systemName: viewModel.isFavorite(username: user.login) ? "star.fill" : "star")
                            .foregroundColor(viewModel.isFavorite(username: user.login) ? .yellow : .primary)
                    } else {
                        Image(systemName: "star")
                            .foregroundColor(.primary)
                    }
                }
                .disabled(!(viewModel.state == .loaded(User.mock(), [])))
                .help("Marcar como favorito")
            }
            
            ToolbarItem {
                Button {
                    if case let .loaded(user, _) = viewModel.state {
                        viewModel.openInBrowser(username: user.login)
                    }
                } label: {
                    Image(systemName: "safari")
                }
                .disabled(!(viewModel.state == .loaded(User.mock(), [])))
                .help("Abrir en el navegador")
            }
        }
    }
    
    @ViewBuilder
    private var detailView: some View {
        switch viewModel.state {
        case .idle:
            ContentUnavailableView {
                Label("Busca un usuario de GitHub", systemImage: "magnifyingglass")
            } description: {
                Text("Ingresa un nombre de usuario en el campo de búsqueda para comenzar.")
            }
            
        case .loading:
            LoadingView(message: "Cargando perfil...", isFullScreen: true)
            
        case let .loaded(user, repositories) where selectedSidebarItem == .profile:
            UserDetailView(user: user)
            
        case let .loaded(user, repositories) where selectedSidebarItem == .repositories:
            RepositoriesListView(
                repositories: repositories,
                searchQuery: $viewModel.searchQuery,
                selectedRepository: $viewModel.selectedRepository,
                onOpenRepository: viewModel.openRepositoryInBrowser
            )
            
        case let .loaded(user, repositories) where selectedSidebarItem == .stats:
            LanguageStatsView(languageStats: viewModel.languageStats)
            
        case .error(let appError):
            ErrorView(error: appError, retryAction: viewModel.fetchUserProfile)
            
        default:
            ContentUnavailableView("Seleccione una opción", systemImage: "sidebar.left")
        }
    }
}

struct UserDetailView: View {
    let user: User
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 20) {
                    AvatarImageView(url: user.avatarURL, size: 120, cornerRadius: 60)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(user.name ?? "")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("@\(user.login)")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        if let location = user.location {
                            Label(location, systemImage: "location")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 16) {
                            StatView(value: user.followers, title: "Seguidores", iconName: "person.2")
                            StatView(value: user.following, title: "Siguiendo", iconName: "person.badge.plus")
                            StatView(value: user.publicRepos, title: "Repositorios", iconName: "book.closed")
                            StatView(value: user.publicGists, title: "Gists", iconName: "text.alignleft")
                        }
                        .padding(.top, 8)
                    }
                    
                    Spacer()
                }
                
                if let bio = user.bio, !bio.isEmpty {
                    #if !os(tvOS)
                    GroupBox("Biografía") {
                        Text(bio)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                    }
                    #else
                    VStack(alignment: .leading) {
                        Text("Biografía")
                            .font(.headline)
                        Text(bio)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                    #endif
                }
                
                Link(destination: URL(string: "https://github.com/\(user.login)")!) {
                    Label("Ver perfil en GitHub", systemImage: "arrow.up.right.square")
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct StatView: View {
    let value: Int
    let title: String
    let iconName: String
    
    var body: some View {
        VStack(spacing: 4) {
            Label("\(value)", systemImage: iconName)
                .font(.headline)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(minWidth: 80)
    }
}

struct RepositoriesListView: View {
    let repositories: [Repository]
    @Binding var searchQuery: String
    @Binding var selectedRepository: Repository?
    let onOpenRepository: (Repository) -> Void
    
    private var filteredRepositories: [Repository] {
        guard !searchQuery.isEmpty else { return repositories }
        return repositories.filter { repo in
            repo.name.localizedCaseInsensitiveContains(searchQuery) ||
            (repo.description?.localizedCaseInsensitiveContains(searchQuery) ?? false)
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Buscar repositorios", text: $searchQuery)
                    .textFieldStyle(.plain)
                
                if !searchQuery.isEmpty {
                    Button {
                        searchQuery = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.borderless)
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
            .padding([.horizontal, .top])
            
            if filteredRepositories.isEmpty {
                ContentUnavailableView("No se encontraron repositorios", systemImage: "magnifyingglass")
            } else {
                List(selection: $selectedRepository) {
                    ForEach(filteredRepositories) { repository in
                        RepositoryItemView(repository: repository) { selectedRepo in
                            selectedRepository = selectedRepo
                        }
                        .tag(repository)
                    }
                }
                #if !os(tvOS)
                .listStyle(.inset)
                #else
                .listStyle(.plain)
                #endif
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
                        Label("Abrir", systemImage: "arrow.up.right.square")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(.thinMaterial)
            }
        }
    }
}

struct LanguageStatsView: View {
    let languageStats: [LanguageStat]
    
    var body: some View {
        VStack {
            if languageStats.isEmpty {
                ContentUnavailableView("No hay estadísticas disponibles", systemImage: "chart.bar.xaxis")
            } else {
                VStack(alignment: .leading) {
                    Text("Distribución de Lenguajes")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    
                    Chart(languageStats) { stat in
                        BarMark(
                            x: .value("Cantidad", stat.count),
                            y: .value("Lenguaje", stat.language)
                        )
                        .foregroundStyle(by: .value("Lenguaje", stat.language))
                        .annotation(position: .trailing) {
                            Text("\(stat.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .chartXAxis(.hidden)
                    .chartForegroundStyleScale(range: colorRange)
                    .frame(height: CGFloat(languageStats.count * 40))
                    .padding()
                    
                    Text("Total de repositorios con lenguaje definido: \(languageStats.reduce(0) { $0 + $1.count })")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding(.top)
                }
                .padding()
            }
        }
    }
    
    private var colorRange: [Color] {
        [.blue, .green, .orange, .purple, .pink, .red, .cyan, .indigo, .yellow, .mint]
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