#if os(visionOS)
import SwiftUI
import RealityKit
import Kingfisher

// Componente específico para visionOS - Versión mejorada para avatar grande
struct UserProfileAvatarView: View {
    let url: URL
    let size: CGFloat
    @State private var rotationAngle = 0.0
    
    var body: some View {
        ZStack(alignment: .center) {
            // Fondo y efectos 3D
            Circle()
                .fill(Color.blue.opacity(0.05))
                .frame(width: size + 20, height: size + 20)
                .shadow(color: .blue.opacity(0.3), radius: 15)
                .rotation3DEffect(
                    .degrees(rotationAngle),
                    axis: (x: 0, y: 1, z: 0.2)
                )
                .onAppear {
                    withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                        rotationAngle = 5
                    }
                }
            
            // Avatar estático superpuesto sobre los efectos 3D
            KFImage(url)
                .placeholder {
                    ZStack {
                        Circle().fill(Color.gray.opacity(0.2))
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .padding(size * 0.25)
                            .foregroundColor(.gray)
                    }
                }
                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: size * 3, height: size * 3)))
                .cacheOriginalImage()
                .loadDiskFileSynchronously()
                .retry(maxCount: 3, interval: .seconds(2))
                .fade(duration: 0.3)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .background(Color.gray.opacity(0.1))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
        }
        .frame(width: size + 20, height: size + 20)
    }
}

// Componente específico para visionOS - Versión para avatares pequeños (barra nav)
struct AvatarImageViewVisionOS: View {
    private let url: URL
    private let size: CGFloat
    private let cornerRadius: CGFloat
    
    init(url: URL, size: CGFloat = 80, cornerRadius: CGFloat = 40) {
        self.url = url
        self.size = size
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        KFImage(url)
            .placeholder {
                ZStack {
                    Color.gray.opacity(0.2)
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(size * 0.25)
                        .foregroundColor(.gray)
                }
            }
            .setProcessor(DownsamplingImageProcessor(size: CGSize(width: size * 2, height: size * 2)))
            .cacheOriginalImage()
            .retry(maxCount: 3, interval: .seconds(2))
            .fade(duration: 0.3)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .background(Color.gray.opacity(0.1))
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct VisionOSUserProfileView: View {
    @ObservedObject var viewModel: VisionOSUserProfileViewModel
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @State private var selectedLanguageFilter: String?
    @State private var searchText = ""
    @State private var rotationAngle = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.black.opacity(0.1), Color.blue.opacity(0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // User profile header with 3D effects
                        VStack {
                            HStack(alignment: .top, spacing: 24) {
                                // Avatar with 3D effect - Reemplazado con componente especializado
                                UserProfileAvatarView(
                                    url: viewModel.user.avatarURL,
                                    size: 150
                                )
                                .frame(width: 170, height: 170)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(viewModel.user.name ?? viewModel.user.login)
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.linearGradient(
                                            colors: [.primary, .secondary],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ))
                                    
                                    Text("@\(viewModel.user.login)")
                                        .font(.title3)
                                        .foregroundColor(.secondary)
                                    
                                    if let location = viewModel.user.location {
                                        Label(location, systemImage: "location")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                            .padding(.top, 2)
                                    }
                                    
                                    HStack(spacing: 20) {
                                        VStack(alignment: .center) {
                                            Text("\(viewModel.user.followers)")
                                                .font(.title2.bold())
                                                .foregroundColor(.primary)
                                            Text("Seguidores")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        VStack(alignment: .center) {
                                            Text("\(viewModel.user.publicRepos)")
                                                .font(.title2.bold())
                                                .foregroundColor(.primary)
                                            Text("Repos")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(.top, 8)
                                    
                                    // Open in GitHub + Immersive mode buttons
                                    HStack(spacing: 16) {
                                        Button {
                                            viewModel.openUserInGitHub()
                                        } label: {
                                            Label("GitHub", systemImage: "safari")
                                                .font(.headline)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 10)
                                                .background(.regularMaterial)
                                                .cornerRadius(10)
                                        }
                                        
                                        Button {
                                            viewModel.toggleImmersiveMode()
                                        } label: {
                                            Label(
                                                viewModel.isInImmersiveSpace ? "2D Mode" : "3D Mode",
                                                systemImage: viewModel.isInImmersiveSpace ? "rectangle.on.rectangle" : "cube"
                                            )
                                            .font(.headline)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(.ultraThinMaterial)
                                            .cornerRadius(10)
                                        }
                                    }
                                    .padding(.top, 8)
                                }
                                
                                Spacer()
                            }
                            .padding(24)
                            .frame(maxWidth: .infinity)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .shadow(color: .black.opacity(0.1), radius: 10)
                            .hoverEffect(.lift)
                        }
                        .padding(.horizontal)
                        
                        // Bio if available
                        if let bio = viewModel.user.bio, !bio.isEmpty {
                            Text(bio)
                                .font(.title3)
                                .padding(24)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .shadow(color: .black.opacity(0.1), radius: 10)
                                .padding(.horizontal)
                                .hoverEffect(.automatic)
                        }
                        
                        // Language filters with 3D effect
                        VStack(alignment: .leading) {
                            Text("Filtrar por lenguaje")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    Button {
                                        selectedLanguageFilter = nil
                                        viewModel.setLanguageFilter(nil)
                                    } label: {
                                        HStack {
                                            Text("Todos")
                                                .font(.headline)
                                            if selectedLanguageFilter == nil {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(selectedLanguageFilter == nil ? Color.blue : Color.secondary.opacity(0.1))
                                        .foregroundColor(selectedLanguageFilter == nil ? .white : .primary)
                                        .clipShape(Capsule())
                                        .shadow(color: selectedLanguageFilter == nil ? .blue.opacity(0.3) : .clear, radius: 5)
                                    }
                                    .buttonStyle(.plain)
                                    .hoverEffect(.highlight)
                                    
                                    ForEach(viewModel.languages, id: \.self) { language in
                                        Button {
                                            selectedLanguageFilter = language
                                            viewModel.setLanguageFilter(language)
                                        } label: {
                                            HStack {
                                                Circle()
                                                    .fill(viewModel.languageColor(for: language))
                                                    .frame(width: 12, height: 12)
                                                
                                                Text(language)
                                                    .font(.headline)
                                                
                                                if selectedLanguageFilter == language {
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                            .background(selectedLanguageFilter == language ? Color.blue : Color.secondary.opacity(0.1))
                                            .foregroundColor(selectedLanguageFilter == language ? .white : .primary)
                                            .clipShape(Capsule())
                                            .shadow(color: selectedLanguageFilter == language ? .blue.opacity(0.3) : .clear, radius: 5)
                                        }
                                        .buttonStyle(.plain)
                                        .hoverEffect(.highlight)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top)
                        
                        // Search for repositories
                        SearchBarView(
                            text: $searchText,
                            placeholder: "Buscar repositorios"
                        )
                        .padding(.horizontal)
                        .padding(.top, 12)
                        .onChange(of: searchText) { _, newValue in
                            viewModel.setSearchQuery(newValue)
                        }
                        
                        // Repositories list
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Repositorios (\(viewModel.filteredRepositories.count))")
                                .font(.title2.bold())
                                .padding(.horizontal)
                            
                            if viewModel.filteredRepositories.isEmpty {
                                VStack(spacing: 20) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 60))
                                        .foregroundColor(.secondary)
                                        .symbolEffect(.pulse)
                                    
                                    Text("No se encontraron repositorios")
                                        .font(.title3.bold())
                                    
                                    Text("Intenta con otra búsqueda o filtro")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 60)
                            } else {
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 350), spacing: 20)], spacing: 20) {
                                    ForEach(viewModel.filteredRepositories) { repository in
                                        VisionOSRepositoryCardView(repository: repository, languageColor: viewModel.languageColor)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 20)
                    }
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle(viewModel.user.login)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        AvatarImageViewVisionOS(url: viewModel.user.avatarURL, size: 30, cornerRadius: 15)
                        Text(viewModel.user.login)
                            .font(.headline)
                    }
                }
            }
            .onChange(of: viewModel.isInImmersiveSpace) { wasActive, isActive in
                Task {
                    if isActive {
                        await openImmersiveSpace(id: ImmersiveSpaceRegistration.immersiveSpaceID)
                        viewModel.updateImmersiveSpace()
                    } else {
                        await dismissImmersiveSpace()
                    }
                }
            }
            .onOpenURL { url in
                if let urlToOpen = viewModel.urlToOpen {
                    openURL(urlToOpen)
                    viewModel.urlToOpen = nil
                }
            }
        }
    }
}

struct VisionOSRepositoryCardView: View {
    let repository: Repository
    let languageColor: (String) -> Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "book.closed")
                    .font(.title3)
                    .foregroundColor(.blue)
                
                Text(repository.name)
                    .font(.title3.bold())
                    .lineLimit(1)
                
                Spacer()
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("\(repository.stargazersCount)")
                        .font(.subheadline.bold())
                }
            }
            
            if let description = repository.description, !description.isEmpty {
                Text(description)
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                if let language = repository.language {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(languageColor(language))
                            .frame(width: 12, height: 12)
                        
                        Text(language)
                            .font(.subheadline)
                    }
                }
                
                Spacer()
                
                Text(repository.updatedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
}

struct VisionOSRepositoryDetailView: View {
    let repository: Repository
    let openURL: (URL) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text(repository.name)
                            .font(.largeTitle.bold())
                        
                        if let language = repository.language {
                            HStack {
                                Circle()
                                    .fill(languageColor(for: language))
                                    .frame(width: 12, height: 12)
                                Text(language)
                                    .font(.headline)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                Divider()
                
                // Description
                if let description = repository.description, !description.isEmpty {
                    Text(description)
                        .font(.title3)
                }
                
                // Stats
                HStack(spacing: 20) {
                    VisionOSStatView(value: repository.stargazersCount, label: "Stars", icon: "star.fill", color: .yellow)
                    VisionOSStatView(value: repository.forksCount, label: "Forks", icon: "tuningfork", color: .green)
                    VisionOSStatView(value: repository.watchersCount, label: "Watchers", icon: "eye.fill", color: .blue)
                }
                .padding(.vertical)
                
                // Dates
                VStack(alignment: .leading, spacing: 10) {
                    VisionOSDateInfoRow(label: "Creado", date: repository.createdAt)
                    VisionOSDateInfoRow(label: "Actualizado", date: repository.updatedAt)
                }
                .padding(.vertical)
                
                Divider()
                
                // Open in GitHub button
                Button {
                    openURL(repository.htmlURL)
                } label: {
                    HStack {
                        Image(systemName: "safari")
                        Text("Ver en GitHub")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .hoverEffect(.highlight)
            }
            .padding(24)
        }
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
        case "html":
            return .orange
        case "css":
            return .blue
        default:
            return .gray
        }
    }
}

struct VisionOSStatView: View {
    let value: Int
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text("\(value)")
                .font(.title2.bold())
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

struct VisionOSDateInfoRow: View {
    let label: String
    let date: Date
    
    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(date.formatted(date: .long, time: .shortened))
                .font(.headline)
        }
    }
}

#Preview {
    NavigationStack {
        VisionOSUserProfileView(
            viewModel: VisionOSUserProfileViewModel(
                fetchUserUseCase: FetchUserUseCase(repository: UserRepository(networkClient: NetworkClient())),
                fetchRepositoriesUseCase: FetchUserRepositoriesUseCase(repository: UserRepository(networkClient: NetworkClient()))
            )
        )
    }
}

#endif 