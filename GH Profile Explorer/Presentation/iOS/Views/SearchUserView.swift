#if os(iOS)
import SwiftUI
import Kingfisher

struct SearchUserView: View {
    @StateObject var viewModel: iOSUserProfileViewModel
    @State private var showAlert = false
    @State private var alertError: AppError?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Logo
                VStack(spacing: 8) {
                    Image(systemName: "person.fill.viewfinder")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .padding(.bottom, 8)
                    
                    Text("GitHub Profile Explorer")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Busca perfiles de desarrolladores en GitHub")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 32)
                
                // Search Bar
                VStack(spacing: 12) {
                    SearchBarView(
                        text: $viewModel.username,
                        placeholder: "Buscar usuario",
                        onSubmit: viewModel.fetchUserProfile
                    )
                    .onTapGesture {
                        viewModel.isShowingSearchHistory = true
                    }
                    
                    // Search History
                    if viewModel.isShowingSearchHistory && !viewModel.searchHistory.isEmpty {
                        searchHistoryView
                    }
                }
                .padding(.horizontal, 8)
                .padding(.top, 16)
                .padding(.bottom, 16)
                
                
                // Search Button
                Button {
                    viewModel.isShowingSearchHistory = false
                    viewModel.fetchUserProfile()
                } label: {
                    Text("Buscar")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue)
                        )
                        .padding(.horizontal, 32)
                }
                .disabled(viewModel.username.isEmpty)
                .opacity(viewModel.username.isEmpty ? 0.6 : 1)
                
                if case .loading = viewModel.state {
                    LoadingView(message: "Buscando usuario...")
                        .transition(.opacity)
                }
                
                Spacer()
                
                // Promotional footer
                VStack {
                    Text("Desarrollado con 💙 usando")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        TechnologyBadgeView(name: "Swift", iconName: "swift")
                        TechnologyBadgeView(name: "SwiftUI", iconName: "swiftui")
                        TechnologyBadgeView(name: "Async/Await", iconName: "clock.arrow.2.circlepath")
                    }
                }
                .padding(.bottom)
            }
            .animation(.easeInOut, value: viewModel.state)
            .animation(.easeInOut, value: viewModel.isShowingSearchHistory)
            .background(
                Color.secondary.opacity(0.05)
                    .edgesIgnoringSafeArea(.all)
            )
            .onTapGesture {
                viewModel.isShowingSearchHistory = false
            }
            .navigationDestination(
                isPresented: Binding<Bool>(
                    get: { viewModel.navigationState != nil },
                    set: { if !$0 { viewModel.navigationState = nil } }
                )
            ) {
                if case let .loaded(user, repositories) = viewModel.state {
                    UserProfileView(user: user, repositories: repositories)
                }
            }
            .onChange(of: viewModel.state) { oldState, newState in
                if case .loaded = newState {
                    viewModel.navigationState = newState
                }
                
                if case let .error(error) = newState {
                    alertError = error
                    showAlert = true
                }
            }
            .alert(isPresented: $showAlert, content: {
                Alert(
                    title: Text("Error"),
                    message: Text(alertError?.localizedDescription ?? "An error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            })
        }
    }
    
    private var searchHistoryView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Búsquedas recientes")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Limpiar") {
                    viewModel.clearSearchHistory()
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            Divider()
                .padding(.top, 8)
            
            List {
                ForEach(viewModel.searchHistory.indices, id: \.self) { index in
                    Button {
                        viewModel.selectHistoryItem(at: index)
                    } label: {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.secondary)
                            Text(viewModel.searchHistory[index])
                                .foregroundColor(.primary)
                            Spacer()
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .background(Color.primary.opacity(0.05))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 5)
        .padding(.horizontal)
        .transition(.opacity)
        .zIndex(1)
    }
}

struct TechnologyBadgeView: View {
    let name: String
    let iconName: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.caption2)
            Text(name)
                .font(.caption2)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(4)
    }
}

#Preview {
    let networkClient = NetworkClient()
    let userRepository = UserRepository(networkClient: networkClient)
    let fetchUserUseCase = FetchUserUseCase(repository: userRepository)
    let fetchRepositoriesUseCase = FetchUserRepositoriesUseCase(repository: userRepository)
    let viewModel = iOSUserProfileViewModel(
        fetchUserUseCase: fetchUserUseCase,
        fetchRepositoriesUseCase: fetchRepositoriesUseCase
    )
    
    return SearchUserView(viewModel: viewModel)
}
#endif
