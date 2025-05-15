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
                sidebarContent
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
        }
    }
    
    private func updateOrientation(geometry: GeometryProxy) {
        let orientation: DeviceOrientation = geometry.size.width > geometry.size.height ? .landscape : .portrait
        viewModel.updateOrientation(orientation)
    }
    
    private var sidebarContent: some View {
        List {
            Section(header: Text("Buscar")) {
                SearchBarView(
                    text: $viewModel.username,
                    placeholder: "Nombre de usuario",
                    onSubmit: viewModel.fetchUserProfile
                )
                .listRowBackground(Color.clear)
                
                Button {
                    viewModel.fetchUserProfile()
                } label: {
                    Label("Buscar", systemImage: "magnifyingglass")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .disabled(viewModel.username.isEmpty)
            }
            
            if !viewModel.searchHistory.isEmpty {
                Section(header: HStack {
                    Text("Historial")
                    
                    Spacer()
                    
                    Button("Limpiar") {
                        viewModel.clearSearchHistory()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }) {
                    ForEach(viewModel.searchHistory, id: \.self) { username in
                        Button {
                            viewModel.selectFromHistory(username)
                        } label: {
                            HStack {
                                Label(username, systemImage: "clock")
                                
                                Spacer()
                                
                                if case let .loaded(user, _) = viewModel.state, user.login == username {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        #if !os(tvOS)
                        .swipeActions {
                            Button(role: .destructive) {
                                viewModel.removeFromHistory(username: username)
                            } label: {
                                Label("Eliminar", systemImage: "trash")
                            }
                        }
                        #endif
                    }
                }
            }
            
            if case let .loaded(user, _) = viewModel.state {
                Section(header: Text("Perfil actual")) {
                    HStack {
                        AvatarImageView(url: user.avatarURL, size: 40, cornerRadius: 20)
                        
                        VStack(alignment: .leading) {
                            Text(user.name ?? user.login)
                                .font(.headline)
                            
                            Text("@\(user.login)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button {
                            viewModel.openInSafari(username: user.login)
                        } label: {
                            Image(systemName: "safari")
                        }
                        .buttonStyle(.borderless)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        #if !os(tvOS)
        .listStyle(.sidebar)
        #else
        .listStyle(.plain)
        #endif
    }
    
    @ViewBuilder
    private func detailContent(user: User, repositories: [Repository], geometry: GeometryProxy) -> some View {
        if isCompactWidth(geometry) {
            // Compact (portrait) - stack content vertically
            ScrollView {
                VStack(spacing: 20) {
                    profileHeader(user: user)
                    
                    repositoriesList(repositories: repositories)
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
                        profileDetail(user: user)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
                        searchRepositoriesBar
                        
                        if viewModel.selectedRepository != nil {
                            repositoryDetailView
                        } else {
                            ScrollView {
                                repositoriesList(repositories: repositories)
                                    .frame(maxWidth: .infinity)
                            }
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
    
    private func profileHeader(user: User) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                AvatarImageView(url: user.avatarURL, size: 100, cornerRadius: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name ?? user.login)
                        .font(.title)
                        .fontWeight(.bold)
                        .lineLimit(1)
                    
                    Text("@\(user.login)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let location = user.location {
                        Label(location, systemImage: "location")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 16) {
                        Label("\(user.followers)", systemImage: "person.2")
                            .font(.subheadline)
                        
                        Label("\(user.following)", systemImage: "person.badge.plus")
                            .font(.subheadline)
                        
                        Label("\(user.publicRepos)", systemImage: "book.closed")
                            .font(.subheadline)
                    }
                    .padding(.top, 4)
                }
                
                Spacer()
                
                Button {
                    viewModel.openInSafari(username: user.login)
                } label: {
                    Label("Ver en GitHub", systemImage: "safari")
                }
                .buttonStyle(.bordered)
            }
            
            if let bio = user.bio, !bio.isEmpty {
                Text(bio)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.primary.opacity(0.05))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5)
        .frame(maxWidth: .infinity)
    }
    
    private func profileDetail(user: User) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            Button {
                viewModel.isDetailExpanded.toggle()
            } label: {
                HStack {
                    Image(systemName: viewModel.isDetailExpanded ? "chevron.left" : "chevron.right")
                    Text(viewModel.isDetailExpanded ? "Comprimir" : "Expandir")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            
            VStack(alignment: .center, spacing: 16) {
                AvatarImageView(url: user.avatarURL, size: 160, cornerRadius: 80)
                    .shadow(color: .black.opacity(0.1), radius: 10)
                
                VStack(spacing: 8) {
                    Text(user.name ?? "")
                        .font(.title)
                        .fontWeight(.bold)
                        .lineLimit(1)
                    
                    Text("@\(user.login)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                Button {
                    viewModel.openInSafari(username: user.login)
                } label: {
                    Label("Ver en GitHub", systemImage: "safari")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                #if !os(tvOS)
                .controlSize(.large)
                #endif
            }
            .frame(maxWidth: .infinity)
            
            if let bio = user.bio, !bio.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Biografía")
                        .font(.headline)
                    
                    Text(bio)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            
            if let location = user.location {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ubicación")
                        .font(.headline)
                    
                    Label(location, systemImage: "location")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Estadísticas")
                    .font(.headline)
                
                HStack(spacing: 16) {
                    statView(count: user.followers, title: "Seguidores", icon: "person.2")
                    statView(count: user.following, title: "Siguiendo", icon: "person.badge.plus")
                    statView(count: user.publicRepos, title: "Repos", icon: "book.closed")
                    if user.publicGists > 0 {
                        statView(count: user.publicGists, title: "Gists", icon: "text.alignleft")
                    }
                }
            }
            
            Button {
                viewModel.showUserQRCode = true
            } label: {
                Label("Compartir perfil", systemImage: "qrcode")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .padding()
        .background(Color.primary.opacity(0.05))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    private func statView(count: Int, title: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
            
            Text("\(count)")
                .font(.headline)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var searchRepositoriesBar: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Buscar repositorios", text: $viewModel.searchQuery)
                    .textFieldStyle(.plain)
                
                if !viewModel.searchQuery.isEmpty {
                    Button {
                        viewModel.searchQuery = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
            
            if viewModel.selectedRepository != nil {
                Button {
                    viewModel.selectedRepository = nil
                } label: {
                    Text("Volver a la lista")
                        .font(.subheadline)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color.primary.opacity(0.05))
    }
    
    @ViewBuilder
    private var repositoryDetailView: some View {
        if let repository = viewModel.selectedRepository {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(repository.name)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            if let language = repository.language {
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(languageColor(for: language))
                                        .frame(width: 12, height: 12)
                                    
                                    Text(language)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Button {
                            viewModel.openRepositoryInSafari(repository)
                        } label: {
                            Label("Ver en GitHub", systemImage: "safari")
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    if let description = repository.description, !description.isEmpty {
                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    HStack(spacing: 30) {
                        statView(count: repository.stargazersCount, title: "Stars", icon: "star.fill")
                        statView(count: repository.forksCount, title: "Forks", icon: "tuningfork")
                        statView(count: repository.watchersCount, title: "Watchers", icon: "eye.fill")
                    }
                    .padding(.vertical)
                    
                    if !repository.topics.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Temas")
                                .font(.headline)
                            
                            FlowLayout(items: repository.topics) { topic in
                                Text(topic)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(4)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private func repositoriesList(repositories: [Repository]) -> some View {
        VStack(spacing: 16) {
            if viewModel.filteredRepositories.isEmpty {
                ContentUnavailableView("No se encontraron repositorios", systemImage: "magnifyingglass")
            } else {
                ForEach(viewModel.filteredRepositories) { repository in
                    RepositoryItemView(repository: repository) { selectedRepo in
                        viewModel.selectedRepository = selectedRepo
                        // Asegurarse de que la vista detalle sea visible en dispositivos pequeños
                        if horizontalSizeClass == .compact {
                            columnVisibility = .detailOnly
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.primary.opacity(0.05))
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.05), radius: 3)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
    
    private func languageColor(for language: String) -> Color {
        switch language.lowercased() {
        case "swift":
            return .orange
        case "javascript", "typescript":
            return .yellow
        case "python":
            return .blue
        case "kotlin":
            return .purple
        case "java":
            return .red
        case "c++", "c":
            return .pink
        case "ruby":
            return .red
        case "go":
            return .cyan
        case "rust":
            return .brown
        default:
            return .gray
        }
    }
}

struct FlowLayout<T: Hashable, V: View>: View {
    let items: [T]
    let spacing: CGFloat
    @ViewBuilder let viewBuilder: (T) -> V
    
    init(
        items: [T],
        spacing: CGFloat = 8,
        @ViewBuilder viewBuilder: @escaping (T) -> V
    ) {
        self.items = items
        self.spacing = spacing
        self.viewBuilder = viewBuilder
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: spacing) {
                // Calculamos las filas manualmente
                let rows = calculateRows(containerWidth: geometry.size.width)
                
                ForEach(0..<rows.count, id: \.self) { rowIndex in
                    HStack(spacing: spacing) {
                        ForEach(rows[rowIndex], id: \.self) { item in
                            viewBuilder(item)
                        }
                    }
                }
            }
        }
    }
    
    private func calculateRows(containerWidth: CGFloat) -> [[T]] {
        var rows: [[T]] = [[]]
        var currentRowWidth: CGFloat = 0
        
        // No podemos medir vistas reales en tiempo de compilación,
        // así que usamos una estimación
        let estimatedItemWidth: CGFloat = 100 + spacing 
        
        for item in items {
            // Si no cabe en la fila actual, crear una nueva
            if currentRowWidth + estimatedItemWidth > containerWidth {
                rows.append([item])
                currentRowWidth = estimatedItemWidth
            } else {
                rows[rows.count - 1].append(item)
                currentRowWidth += estimatedItemWidth
            }
        }
        
        return rows
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
