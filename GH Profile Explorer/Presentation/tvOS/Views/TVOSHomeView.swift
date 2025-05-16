#if os(tvOS)
import SwiftUI

struct TVOSHomeView: View {
    private enum Constants {
        enum Strings {
            static let appTitle = "github_profile_explorer"
            static let loading = "loading"
            static let error = "error"
            static let ok = "ok"
            static let searchPlaceholder = "search_github_user"
            static let featuredUsers = "featured_users"
            static let recentSearches = "recent_searches"
            static let search = "search"
            static let profile = "profile"
            static let repositories = "repositories"
        }
        
        enum Images {
            static let logo = "person.fill.viewfinder"
            static let search = "magnifyingglass"
            static let profile = "person"
            static let repositories = "book.closed"
        }
        
        enum Layout {
            static let mainSpacing: CGFloat = 40
            static let titleSpacing: CGFloat = 20
            static let headerTopPadding: CGFloat = 60
            static let searchHorizontalPadding: CGFloat = 60
            static let searchItemSpacing: CGFloat = 20
            static let sectionSpacing: CGFloat = 40
            static let sectionItemSpacing: CGFloat = 24
            static let logoSize: CGFloat = 100
            static let menuHorizontalSpacing: CGFloat = 40
            static let menuBottomPadding: CGFloat = 60
            static let searchFieldPaddingH: CGFloat = 25
            static let searchFieldPaddingV: CGFloat = 20
            static let searchFieldCornerRadius: CGFloat = 10
            static let searchFieldBorderWidth: CGFloat = 5
            static let searchFieldHeight: CGFloat = 80
            static let searchButtonWidth: CGFloat = 200
            static let delayOnAppear: Double = 0.5
            static let sectionTitlePadding: CGFloat = 40
        }
        
        enum Colors {
            static let gradientStart = Color.blue.opacity(0.2)
            static let gradientEnd = Color.black
            static let searchFieldBackground = Color.black.opacity(0.7)
            static let searchFieldBorder = Color.white
            static let searchFieldText = Color.white
            static let searchFieldPlaceholder = Color.gray.opacity(0.7)
            static let errorBackground = Color.black.opacity(0.7)
            static let sectionTitle = Color.white.opacity(0.9)
        }
    }
    
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
                    if let user = viewModel.userUI {
                        TVOSProfileView(user: user, viewModel: viewModel)
                    }
                    
                case .repositories:
                    // Volvemos a la pantalla de búsqueda si intentamos ir a la sección eliminada
                    homeScreen
                }
                
                if case .loading = viewModel.state {
                    LoadingView(
                        message: Constants.Strings.loading.localized, 
                        isFullScreen: true
                    )
                    .background(Constants.Colors.errorBackground)
                }
            }
            .navigationTitle("")
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
                    title: Text(Constants.Strings.error.localized),
                    message: Text(error?.localizedDescription ?? "An error occurred"),
                    dismissButton: .default(Text(Constants.Strings.ok.localized))
                )
            }
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [Constants.Colors.gradientStart, Constants.Colors.gradientEnd]),
            startPoint: .top,
            endPoint: .bottom
        )
        .edgesIgnoringSafeArea(.all)
    }
    
    private var homeScreen: some View {
        VStack(spacing: Constants.Layout.mainSpacing) {
            // Logo and title
            VStack(spacing: Constants.Layout.titleSpacing) {
                Text(Constants.Strings.appTitle.localized)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.top, Constants.Layout.headerTopPadding)
            
            // Search section
            VStack(spacing: Constants.Layout.sectionSpacing) {
                // Search bar
                HStack(spacing: Constants.Layout.searchItemSpacing) {
                    HStack {
                        Image(systemName: Constants.Images.search)
                            .font(.system(size: 24))
                            .foregroundColor(focusedSection == .search ? Constants.Colors.searchFieldText : Constants.Colors.searchFieldPlaceholder)
                            .padding(.leading, Constants.Layout.searchFieldPaddingH)
                        
                        TextField(Constants.Strings.searchPlaceholder.localized, text: $viewModel.username)
                            .textFieldStyle(.plain)
                            .font(.title3)
                            .foregroundColor(Constants.Colors.searchFieldText)
                            .padding(.vertical, Constants.Layout.searchFieldPaddingV)
                    }
                    .frame(height: Constants.Layout.searchFieldHeight)
                    .background(
                        RoundedRectangle(cornerRadius: Constants.Layout.searchFieldCornerRadius)
                            .fill(Constants.Colors.searchFieldBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: Constants.Layout.searchFieldCornerRadius)
                                    .stroke(
                                        focusedSection == .search ? Constants.Colors.searchFieldBorder : Color.clear, 
                                        lineWidth: Constants.Layout.searchFieldBorderWidth
                                    )
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
                    .scaleEffect(focusedSection == .search ? 1.02 : 1.0)
                    .animation(.spring(response: 0.3), value: focusedSection == .search)
                }
                .padding(.horizontal, Constants.Layout.searchHorizontalPadding)
                
                // Featured users
                VStack(alignment: .leading, spacing: Constants.Layout.sectionItemSpacing) {
                    Text(Constants.Strings.featuredUsers.localized.uppercased())
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.sectionTitle)
                        .padding(.horizontal, Constants.Layout.sectionTitlePadding)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Constants.Layout.sectionItemSpacing) {
                            ForEach(viewModel.featuredUsers, id: \.self) { username in
                                TVOSFeaturedUserButton(username: username) {
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
                        .padding(.horizontal, Constants.Layout.sectionTitlePadding)
                        .padding(.vertical, 16)
                    }
                    .padding(.bottom, 10)
                }
                
                // Recent searches
                if !viewModel.recentSearches.isEmpty {
                    VStack(alignment: .leading, spacing: Constants.Layout.sectionItemSpacing) {
                        HStack {
                            Text(Constants.Strings.recentSearches.localized.uppercased())
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(Constants.Colors.sectionTitle)
                            
                            Spacer()
                            
                            TVOSClearButton {
                                viewModel.clearRecentSearches()
                            }
                        }
                        .padding(.horizontal, Constants.Layout.sectionTitlePadding)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Constants.Layout.searchItemSpacing) {
                                ForEach(viewModel.recentSearches, id: \.self) { username in
                                    TVOSRecentSearchButton(username: username) {
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
                            .padding(.horizontal, Constants.Layout.sectionTitlePadding)
                            .padding(.vertical, 20)
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            
            Spacer()
            
            // Menu footer
            HStack(spacing: Constants.Layout.menuHorizontalSpacing) {
                TVOSButtonCard(icon: Constants.Images.search, title: Constants.Strings.search.localized) {
                    viewModel.selectedSection = .search
                    focusedSection = .search
                }
                
                if case .loaded = viewModel.state {
                    TVOSButtonCard(icon: Constants.Images.profile, title: Constants.Strings.profile.localized) {
                        viewModel.selectedSection = .profile
                    }
                }
            }
            .padding(.bottom, Constants.Layout.menuBottomPadding)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Layout.delayOnAppear) {
                focusedSection = .search
            }
        }
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
