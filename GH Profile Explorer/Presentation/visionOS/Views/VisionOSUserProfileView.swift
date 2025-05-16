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
    private enum Constants {
        enum Strings {
            static let search = "search"
            static let searchUser = "search_user"
            static let noRepositoriesFound = "no_repositories_found"
            static let tryDifferentSearch = "try_different_search"
            static let searchRepositories = "search_repositories"
            static let repositories = "repositories"
            static let recentSearches = "recent_searches"
            static let clearAll = "clear_all"
            static let cancel = "cancel"
            static let loadingProfile = "loading_profile"
            static let searchForUsers = "search_for_users"
            static let enterUsername = "enter_username"
            static let viewRecentSearches = "view_recent_searches"
        }
        
        enum Layout {
            static let contentPadding: CGFloat = 24
            static let sectionSpacing: CGFloat = 20
            static let gridSpacing: CGFloat = 20
        }
        
        enum Colors {
            static let background = Color.clear
        }
        
        enum Images {
            static let search = "magnifyingglass"
            static let clock = "clock"
            static let person = "person.fill.questionmark"
        }
    }
    
    @StateObject var viewModel: VisionOSUserProfileViewModel
    @State private var searchText = ""
    @State private var showSearchBar = true
    @Environment(\.openURL) private var openURLAction
    
    var body: some View {
        ZStack {
            Constants.Colors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Search bar (condicional)
                if showSearchBar {
                    searchBarSection
                }
                
                // Main content
                ScrollView {
                    VStack(spacing: Constants.Layout.sectionSpacing) {
                        if let user = viewModel.userUI {
                            // Profile header
                            VisionOSProfileHeaderView(
                                user: user,
                                onOpenGitHubProfile: viewModel.openUserInGitHub
                            )
                            
                            // Repositories title
                            Text(Constants.Strings.repositories.localized)
                                .font(.title.bold())
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Repositories grid
                            repositoriesSection
                        } else if case .error = viewModel.state {
                            errorView
                        } else if case .loading = viewModel.state {
                            loadingView
                        } else {
                            emptyView
                        }
                    }
                    .padding(Constants.Layout.contentPadding)
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                    withAnimation {
                        showSearchBar = offset <= 5
                    }
                }
            }
        }
        .onChange(of: searchText) { _, newValue in
            viewModel.setSearchQuery(newValue)
        }
        .onChange(of: viewModel.urlToOpen) { _, url in
            if let url = url {
                openURLAction(url)
            }
        }
        .sheet(isPresented: $viewModel.isShowingSearchHistory) {
            searchHistoryView
        }
    }
    
    // MARK: - View Components
    
    private var searchBarSection: some View {
        HStack {
            Button {
                viewModel.isShowingSearchHistory = true
            } label: {
                Image(systemName: Constants.Images.search)
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            
            VisionOSSearchBarView(
                text: $viewModel.username,
                placeholder: Constants.Strings.searchUser.localized
            ) {
                viewModel.fetchUserProfile()
            }
            
            Button {
                viewModel.fetchUserProfile()
            } label: {
                Text(Constants.Strings.search.localized)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .keyboardShortcut(.defaultAction)
        }
        .padding()
        .background(.ultraThinMaterial)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    private var repositoriesSection: some View {
        VStack(alignment: .leading, spacing: Constants.Layout.sectionSpacing) {
            // Search bar for repositories
            VisionOSSearchBarView(
                text: $searchText,
                placeholder: Constants.Strings.searchRepositories.localized
            ) {
                // Ejecutar explícitamente la búsqueda cuando se envía
                viewModel.setSearchQuery(searchText)
            }
            .padding(.horizontal)
            .background(GeometryReader { proxy in
                Color.clear
                    .preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: proxy.frame(in: .named("scroll")).minY
                    )
            })
            
            // Repositories grid or empty state
            if viewModel.filteredRepositoriesUI.isEmpty {
                VisionOSEmptyStateView(
                    icon: Constants.Images.search,
                    title: Constants.Strings.noRepositoriesFound.localized,
                    message: Constants.Strings.tryDifferentSearch.localized
                )
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 350), spacing: Constants.Layout.gridSpacing)
                    ],
                    spacing: Constants.Layout.gridSpacing
                ) {
                    ForEach(viewModel.filteredRepositoriesUI) { repository in
                        VisionOSRepositoryCardView(repository: repository)
                            .onTapGesture {
                                viewModel.openRepositoryInBrowser(repository)
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var searchHistoryView: some View {
        NavigationStack {
            List {
                ForEach(viewModel.searchHistory, id: \.self) { item in
                    Button {
                        viewModel.username = item
                        viewModel.isShowingSearchHistory = false
                        viewModel.fetchUserProfile()
                    } label: {
                        HStack {
                            Image(systemName: Constants.Images.clock)
                                .foregroundColor(.secondary)
                            Text(item)
                                .foregroundColor(.primary)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        if index < viewModel.searchHistory.count {
                            viewModel.removeSearchHistoryItem(at: index)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(Constants.Strings.recentSearches.localized)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.clearSearchHistory()
                    } label: {
                        Text(Constants.Strings.clearAll.localized)
                    }
                    .disabled(viewModel.searchHistory.isEmpty)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        viewModel.isShowingSearchHistory = false
                    } label: {
                        Text(Constants.Strings.cancel.localized)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    private var loadingView: some View {
        VisionOSLoadingView(message: Constants.Strings.loadingProfile.localized)
    }
    
    private var errorView: some View {
        if case let .error(error) = viewModel.state {
            return AnyView(
                VisionOSErrorView(error: error) {
                    viewModel.fetchUserProfile()
                }
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    private var emptyView: some View {
        VisionOSEmptyStateView(
            icon: Constants.Images.person,
            title: Constants.Strings.searchForUsers.localized,
            message: Constants.Strings.enterUsername.localized,
            action: {
                viewModel.isShowingSearchHistory = true
            },
            actionLabel: Constants.Strings.viewRecentSearches.localized
        )
    }
}

// PreferenceKey para detectar el desplazamiento del scroll
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    let viewModel = VisionOSUserProfileViewModel(
        manageSearchHistoryUseCase: nil, 
        filterRepositoriesUseCase: nil, 
        openURLUseCase: nil
    )
    
    // Configuramos un estado con datos mock
    let user = User.mock()
    let repositories = [Repository.mock(), Repository.mock()]
    viewModel.state = VisionOSViewState.loaded(user, repositories)
    
    return VisionOSUserProfileView(viewModel: viewModel)
}

#endif 
