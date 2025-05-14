#if os(tvOS)
import SwiftUI

struct TVOSHomeView: View {
    @StateObject var viewModel: tvOSUserProfileViewModel
    @FocusState private var focusedSection: TVSection?
    @State private var showError = false
    @State private var error: AppError?
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                
                switch viewModel.selectedSection {
                case .search, .featured, .recent:
                    homeScreen
                    
                case .profile:
                    if case let .loaded(user, _) = viewModel.state {
                        TVOSProfileView(user: user)
                    }
                    
                case .repositories:
                    if case let .loaded(_, repositories) = viewModel.state {
                        TVOSRepositoriesView(repositories: repositories)
                    }
                }
                
                if case .loading = viewModel.state {
                    LoadingView(message: "Cargando...", isFullScreen: true)
                        .background(Color.black.opacity(0.7))
                }
            }
            .navigationTitle("GitHub Profile Explorer")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .onChange(of: viewModel.state) { oldValue, newValue in
                if case let .error(newError) = newValue {
                    error = newError
                    showError = true
                }
                
                if case .loaded = newValue {
                    viewModel.selectedSection = .profile
                }
            }
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(error?.localizedDescription ?? "An error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.black]),
            startPoint: .top,
            endPoint: .bottom
        )
        .edgesIgnoringSafeArea(.all)
    }
    
    private var homeScreen: some View {
        VStack(spacing: 40) {
            // Logo and title
            VStack(spacing: 20) {
                Image(systemName: "person.fill.viewfinder")
                    .font(.system(size: 100))
                    .foregroundColor(.white)
                
                Text("GitHub Profile Explorer")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.top, 60)
            
            // Search section
            VStack(spacing: 30) {
                // Search bar
                HStack(spacing: 20) {
                    TextField("Buscar usuario de GitHub", text: $viewModel.username)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.black.opacity(0.5))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(focusedSection == .search ? Color.white : Color.clear, lineWidth: 4)
                                )
                        )
                        .focused($focusedSection, equals: .search)
                        .onChange(of: focusedSection) { oldValue, newValue in
                            if newValue == .search {
                                viewModel.selectedSection = .search
                            }
                        }
                        .onSubmit {
                            viewModel.fetchUserProfile()
                        }
                    
                    SearchButton {
                        viewModel.fetchUserProfile()
                    }
                    .focused($focusedSection, equals: .search)
                }
                .padding(.horizontal, 100)
                
                // Featured users
                VStack(alignment: .leading, spacing: 20) {
                    Text("USUARIOS DESTACADOS")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 30) {
                            ForEach(viewModel.featuredUsers, id: \.self) { username in
                                FeaturedUserButton(username: username) {
                                    viewModel.selectFeaturedUser(username)
                                }
                                .focused($focusedSection, equals: .featured)
                                .onChange(of: focusedSection) { oldValue, newValue in
                                    if newValue == .featured {
                                        viewModel.selectedSection = .featured
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Recent searches
                if !viewModel.recentSearches.isEmpty {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("BÚSQUEDAS RECIENTES")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            ClearButton {
                                viewModel.clearRecentSearches()
                            }
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(viewModel.recentSearches, id: \.self) { username in
                                    RecentSearchButton(username: username) {
                                        viewModel.username = username
                                        viewModel.fetchUserProfile()
                                    }
                                    .focused($focusedSection, equals: .recent)
                                    .onChange(of: focusedSection) { oldValue, newValue in
                                        if newValue == .recent {
                                            viewModel.selectedSection = .recent
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Menu footer
            HStack(spacing: 40) {
                TVButtonCard(icon: "magnifyingglass", title: "Buscar") {
                    viewModel.selectedSection = .search
                    focusedSection = .search
                }
                
                if case .loaded = viewModel.state {
                    TVButtonCard(icon: "person", title: "Perfil") {
                        viewModel.selectedSection = .profile
                    }
                    
                    TVButtonCard(icon: "book.closed", title: "Repositorios") {
                        viewModel.selectedSection = .repositories
                    }
                }
            }
            .padding(.bottom, 60)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focusedSection = .search
            }
        }
    }
}

struct TVOSProfileView: View {
    let user: User
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                // Profile header
                VStack(spacing: 30) {
                    AvatarImageView(url: user.avatarURL, size: 220, cornerRadius: 110)
                        .shadow(color: .blue.opacity(0.5), radius: 20)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 6)
                                .opacity(0.3)
                        )
                    
                    VStack(spacing: 12) {
                        Text(user.name ?? user.login)
                            .font(.system(size: 48))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("@\(user.login)")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top, 20)
                
                // User stats
                HStack(spacing: 50) {
                    StatCard(value: user.followers, title: "Seguidores", icon: "person.2.fill")
                    StatCard(value: user.following, title: "Siguiendo", icon: "person.badge.plus")
                    StatCard(value: user.publicRepos, title: "Repositorios", icon: "book.closed.fill")
                    StatCard(value: user.publicGists, title: "Gists", icon: "text.alignleft")
                }
                
                // Bio
                if let bio = user.bio, !bio.isEmpty {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("BIOGRAFÍA")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text(bio)
                            .font(.body)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.4))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                            )
                    )
                    .padding(.horizontal, 80)
                }
                
                // Location
                if let location = user.location {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                        
                        Text(location)
                            .foregroundColor(.white)
                    }
                    .font(.title2)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.4))
                    )
                }
            }
            .padding(60)
            .background(Color.black.opacity(0.2))
        }
    }
}

struct TVOSRepositoriesView: View {
    let repositories: [Repository]
    @State private var selectedRepository: Repository?
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            if let selected = selectedRepository {
                // Repository detail
                VStack(spacing: 25) {
                    VStack(spacing: 10) {
                        Text(selected.name)
                            .font(.system(size: 48))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        if let language = selected.language {
                            HStack {
                                Circle()
                                    .fill(languageColor(for: language))
                                    .frame(width: 18, height: 18)
                                
                                Text(language)
                                    .font(.title2)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    if let description = selected.description, !description.isEmpty {
                        Text(description)
                            .font(.title2)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 80)
                    }
                    
                    HStack(spacing: 60) {
                        Label("\(selected.stargazersCount)", systemImage: "star.fill")
                            .foregroundColor(.yellow)
                        
                        Label("\(selected.forksCount)", systemImage: "tuningfork")
                            .foregroundColor(.gray)
                        
                        Label("\(selected.watchersCount)", systemImage: "eye.fill")
                            .foregroundColor(.gray)
                    }
                    .font(.title2)
                    .padding(.top)
                    
                    if !selected.topics.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(selected.topics, id: \.self) { topic in
                                    Text(topic)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 15)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.blue.opacity(0.3))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(Color.blue.opacity(0.6), lineWidth: 2)
                                                )
                                        )
                                }
                            }
                        }
                        .padding(.top)
                    }
                    
                    Button("Ver en GitHub") {
                        // Would show QR code in real implementation
                    }
                    .buttonStyle(TVFocusableButtonStyle(color: .blue))
                    .padding(.top, 30)
                }
                .padding(40)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        )
                )
                .padding()
            }
            
            // Repository list
            Text("REPOSITORIOS")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.top, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 30) {
                    ForEach(repositories) { repo in
                        Button {
                            selectedRepository = repo
                        } label: {
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Image(systemName: repo.fork ? "tuningfork" : "book.closed")
                                        .foregroundColor(repo.fork ? .orange : .blue)
                                        .font(.title2)
                                    
                                    Text(repo.name)
                                        .lineLimit(1)
                                        .foregroundColor(.white)
                                        .font(.title3)
                                }
                                
                                if let description = repo.description, !description.isEmpty {
                                    Text(description)
                                        .lineLimit(2)
                                        .font(.body)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                HStack {
                                    if let language = repo.language {
                                        HStack(spacing: 4) {
                                            Circle()
                                                .fill(languageColor(for: language))
                                                .frame(width: 12, height: 12)
                                            
                                            Text(language)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Label("\(repo.stargazersCount)", systemImage: "star.fill")
                                        .font(.subheadline)
                                        .foregroundColor(.yellow)
                                }
                            }
                            .padding(20)
                            .frame(width: 320, height: 200)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(selectedRepository?.id == repo.id ? Color.blue.opacity(0.3) : Color.black.opacity(0.4))
                            )
                        }
                        .buttonStyle(TVFocusableButtonStyle())
                        .focused($isFocused)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
        }
        .onAppear {
            if let first = repositories.first {
                selectedRepository = first
            }
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
        default:
            return .gray
        }
    }
}

struct StatCard: View {
    let value: Int
    let title: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(.blue)
            
            Text("\(value)")
                .font(.system(size: 32))
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
        }
        .frame(width: 180, height: 160)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                )
        )
    }
}

struct TVFocusableButtonStyle: ButtonStyle {
    var color: Color = .white
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .brightness(configuration.isPressed ? 0.3 : 0)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .shadow(color: configuration.isPressed ? color : Color.clear, radius: 10)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
            .contentShape(Rectangle())
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color, lineWidth: 4)
                    .opacity(0)
                    .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
            )
    }
}

struct TVButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.headline)
                Text(title)
                    .font(.headline)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 25)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue)
            )
        }
        .buttonStyle(TVFocusableButtonStyle())
    }
}

struct TVMenuButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(width: 150, height: 100)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.5))
            )
        }
        .buttonStyle(TVFocusableButtonStyle())
    }
}

struct TVButtonCard: View {
    let icon: String
    let title: String
    let action: () -> Void
    @FocusState private var focused: Bool
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding()
            .frame(width: 180, height: 120)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white, lineWidth: focused ? 4 : 0)
            )
            .scaleEffect(focused ? 1.1 : 1.0)
            .animation(.spring(), value: focused)
        }
        .buttonStyle(.card)
        .focused($focused)
    }
}

struct SearchButton: View {
    let action: () -> Void
    @FocusState private var focused: Bool
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.headline)
                Text("Buscar")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 25)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white, lineWidth: focused ? 4 : 0)
            )
            .scaleEffect(focused ? 1.05 : 1.0)
            .animation(.spring(), value: focused)
        }
        .buttonStyle(.card)
        .focused($focused)
    }
}

struct ClearButton: View {
    let action: () -> Void
    @FocusState private var focused: Bool
    
    var body: some View {
        Button(action: action) {
            Text("Limpiar")
                .foregroundColor(.white)
                .font(.headline)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.7))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white, lineWidth: focused ? 3 : 0)
                )
                .scaleEffect(focused ? 1.05 : 1.0)
        }
        .buttonStyle(.card)
        .focused($focused)
    }
}

struct FeaturedUserButton: View {
    let username: String
    let action: () -> Void
    @FocusState private var focused: Bool
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 15) {
                ZStack {
                    if let url = URL(string: "https://github.com/\(username).png") {
                        AvatarImageView(url: url, size: 140, cornerRadius: 70)
                            .shadow(color: .blue.opacity(0.5), radius: focused ? 15 : 5)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 140, height: 140)
                            .clipShape(Circle())
                            .foregroundColor(.gray)
                    }
                }
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: focused ? 4 : 0)
                )
                
                Text(username)
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .frame(width: 180, height: 220)
            .scaleEffect(focused ? 1.1 : 1.0)
            .animation(.spring(), value: focused)
        }
        .buttonStyle(.card)
        .focused($focused)
    }
}

struct RecentSearchButton: View {
    let username: String
    let action: () -> Void
    @FocusState private var focused: Bool
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "clock")
                    .foregroundColor(.white)
                
                Text(username)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 20)
            .frame(height: 70)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white, lineWidth: focused ? 4 : 0)
            )
            .scaleEffect(focused ? 1.05 : 1.0)
            .animation(.spring(), value: focused)
        }
        .buttonStyle(.card)
        .focused($focused)
    }
}



#Preview {
    let networkClient = NetworkClient()
    let userRepository = UserRepository(networkClient: networkClient)
    let fetchUserUseCase = FetchUserUseCase(repository: userRepository)
    let fetchRepositoriesUseCase = FetchUserRepositoriesUseCase(repository: userRepository)
    let viewModel = tvOSUserProfileViewModel(
        fetchUserUseCase: fetchUserUseCase,
        fetchRepositoriesUseCase: fetchRepositoriesUseCase
    )
    
    return TVOSHomeView(viewModel: viewModel)
} 
#endif
