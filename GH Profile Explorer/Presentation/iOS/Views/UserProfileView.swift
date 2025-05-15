#if os(iOS)
import SwiftUI

struct UserProfileView: View {
    @ObservedObject var viewModel: iOSUserProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    private enum Constants {
        enum Images {
            static let safari = "safari"
            static let error = "exclamationmark.triangle"
        }
        
        enum Keys {
            static let loading = "loading_profile"
            static let error = "error_prefix"
            static let retry = "retry"
            static let noProfile = "no_profile"
            static let searchPlaceholder = "search_repositories"
        }
        
        enum Layout {
            static let contentSpacing: CGFloat = 16
            static let avatarSize: CGFloat = 30
            static let avatarCornerRadius: CGFloat = 15
            static let errorIconSize: CGFloat = 50
            static let buttonCornerRadius: CGFloat = 8
            static let searchBarPadding: CGFloat = 8
            static let searchBarExtraPadding: CGFloat = -16
            static let padding: CGFloat = 16
        }
        
        enum Colors {
            static let background = Color.secondary.opacity(0.05)
        }
    }
    
    var body: some View {
        ScrollView {
            switch viewModel.state {
            case .loaded:
                contentView
            case .loading:
                loadingView
            case .error(let error):
                errorView(error)
            case .idle:
                idleView
            }
        }
        .background(Constants.Colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(viewModel.username)
        .toolbar {
            ToolbarItem(placement: .principal) {
                if let user = viewModel.userUI {
                    HStack {
                        AvatarImageView(url: user.avatarURL, size: Constants.Layout.avatarSize, cornerRadius: Constants.Layout.avatarCornerRadius)
                        Text(user.login)
                            .font(.headline)
                    }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if let url = viewModel.openGitHubProfile() {
                        openURL(url)
                    }
                } label: {
                    Image(systemName: Constants.Images.safari)
                }
            }
        }
        .onAppear {
            if case .idle = viewModel.state {
                viewModel.fetchUserProfile()
            }
        }
    }
    
    // MARK: - Content Views
    
    private var contentView: some View {
        VStack(alignment: .leading, spacing: Constants.Layout.contentSpacing) {
            if let user = viewModel.userUI {
                UserProfileHeaderView(user: user)
                
                UserBioView(bio: user.bio)
                
                LanguageFiltersView(
                    languages: viewModel.languagesUI,
                    selectedLanguage: $viewModel.selectedLanguageFilter
                )
                
                SearchBarView(
                    text: $viewModel.searchText,
                    placeholder: Constants.Keys.searchPlaceholder.localized
                )
                .padding(.top, Constants.Layout.searchBarPadding)
                .padding(.bottom, Constants.Layout.searchBarPadding)
                .padding(.leading, Constants.Layout.searchBarExtraPadding)
                .padding(.trailing, Constants.Layout.searchBarExtraPadding)
                
                RepositoryListView(repositories: viewModel.filteredRepositoriesUI)
            }
        }
        .padding(Constants.Layout.padding)
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
            Text(Constants.Keys.loading.localized)
                .foregroundColor(.secondary)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(_ error: AppError) -> some View {
        VStack {
            Image(systemName: Constants.Images.error)
                .font(.system(size: Constants.Layout.errorIconSize))
                .foregroundColor(.red)
                .padding()
            
            Text(Constants.Keys.error.localized + error.localizedDescription)
                .multilineTextAlignment(.center)
                .padding()
            
            Button(Constants.Keys.retry.localized) {
                viewModel.fetchUserProfile()
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(Constants.Layout.buttonCornerRadius)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var idleView: some View {
        VStack {
            Text(Constants.Keys.noProfile.localized)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NavigationStack {
        let networkClient = NetworkClient()
        let userRepository = UserRepository(networkClient: networkClient)
        let fetchUserUseCase = FetchUserUseCase(repository: userRepository)
        let fetchRepositoriesUseCase = FetchUserRepositoriesUseCase(repository: userRepository)
        let viewModel = iOSUserProfileViewModel(
            fetchUserUseCase: fetchUserUseCase,
            fetchRepositoriesUseCase: fetchRepositoriesUseCase
        )
        
        viewModel.username = "josepescobar"
        
        return UserProfileView(viewModel: viewModel)
    }
}
#endif 
