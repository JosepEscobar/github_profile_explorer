#if os(macOS)
import SwiftUI

// Enumeración común para ambas plataformas
enum SidebarItem: Hashable {
    case search
    case profile
    case repositories
    case stats
    case favorites
}

struct SidebarView: View {
    @ObservedObject var viewModel: macOSUserProfileViewModel
    @Binding var selectedSidebarItem: SidebarItem
    @State private var isShowingSearchField = false
    
    var body: some View {
        // Implementación específica para macOS
        MacOSSidebarContent(
            viewModel: viewModel,
            selectedSidebarItem: $selectedSidebarItem,
            isShowingSearchField: $isShowingSearchField
        )
    }
}

// Implementación de macOS
private struct MacOSSidebarContent: View {
    @ObservedObject var viewModel: macOSUserProfileViewModel
    @Binding var selectedSidebarItem: SidebarItem
    @Binding var isShowingSearchField: Bool
    
    var body: some View {
        List(selection: $selectedSidebarItem) {
            Section("Buscar") {
                HStack {
                    if isShowingSearchField {
                        TextField("Nombre de usuario", text: $viewModel.username)
                            .textFieldStyle(.plain)
                            .onSubmit {
                                viewModel.fetchUserProfile()
                                selectedSidebarItem = .profile
                            }
                        
                        Button {
                            isShowingSearchField = false
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Text("Buscar usuario")
                        
                        Spacer()
                        
                        Button {
                            isShowingSearchField = true
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
                .tag(SidebarItem.search)
            }
            
            if case let .loaded(user, _) = viewModel.state {
                Section("Usuario actual") {
                    NavigationLink(value: SidebarItem.profile) {
                        UserRowView(user: user, isCurrent: true)
                    }
                    
                    NavigationLink(value: SidebarItem.repositories) {
                        Label("Repositorios", systemImage: "book.closed")
                    }
                    
                    NavigationLink(value: SidebarItem.stats) {
                        Label("Estadísticas", systemImage: "chart.bar")
                    }
                }
            }
            
            Section("Favoritos") {
                if viewModel.favoriteUsernames.isEmpty {
                    Text("No hay favoritos")
                        .foregroundColor(.secondary)
                        .font(.caption)
                } else {
                    ForEach(viewModel.favoriteUsernames, id: \.self) { username in
                        Button {
                            viewModel.username = username
                            viewModel.fetchUserProfile()
                            selectedSidebarItem = .profile
                        } label: {
                            HStack {
                                Label(username, systemImage: "person")
                                
                                Spacer()
                                
                                Button {
                                    viewModel.removeFromFavorites(username: username)
                                } label: {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        #if !os(tvOS)
        .listStyle(.sidebar)
        #else
        .listStyle(.plain)
        #endif
        .frame(minWidth: 200)
    }
}

struct UserRowView: View {
    let user: User
    let isCurrent: Bool
    
    var body: some View {
        HStack {
            AsyncImage(url: user.avatarURL) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else if phase.error != nil {
                    Image(systemName: "person.fill")
                        .foregroundColor(.white)
                } else {
                    ProgressView()
                }
            }
            .frame(width: 24, height: 24)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
            
            VStack(alignment: .leading) {
                Text(user.name ?? user.login)
                    .font(.headline)
                
                if !isCurrent {
                    Text("@\(user.login)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

#Preview {
    NavigationSplitView {
        SidebarView(
            viewModel: macOSUserProfileViewModel(
                fetchUserUseCase: FetchUserUseCase(repository: UserRepository(networkClient: NetworkClient())),
                fetchRepositoriesUseCase: FetchUserRepositoriesUseCase(repository: UserRepository(networkClient: NetworkClient()))
            ),
            selectedSidebarItem: .constant(.profile)
        )
    } detail: {
        Text("Select an item")
    }
}
#endif 