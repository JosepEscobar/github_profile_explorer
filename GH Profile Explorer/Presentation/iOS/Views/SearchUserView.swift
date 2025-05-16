#if os(iOS)
import SwiftUI
import Kingfisher

struct SearchUserView: View {
    @StateObject var viewModel: iOSUserProfileViewModel
    @State private var showAlert = false
    @State private var alertError: AppError?
    
    private enum Constants {
        enum Images {
            static let logo = "person.fill.viewfinder"
            static let clock = "clock"
        }
        
        enum Keys {
            static let title = "app_title"
            static let subtitle = "app_subtitle"
            static let searchPlaceholder = "search_placeholder"
            static let searchButton = "search_button"
            static let loadingMessage = "loading_user"
            static let recentSearches = "recent_searches"
            static let clearButton = "clear"
            static let footer = "footer_text"
            static let errorTitle = "error"
            static let errorDismiss = "ok"
            static let defaultErrorMessage = "default_error"
        }
        
        enum Layout {
            static let logoSize: CGFloat = 60
            static let logoBottomPadding: CGFloat = 8
            static let contentSpacing: CGFloat = 24
            static let vStackSpacing: CGFloat = 8
            static let searchBarSpacing: CGFloat = 12
            static let topPadding: CGFloat = 32
            static let horizontalPadding: CGFloat = 8
            static let buttonPadding: CGFloat = 32
            static let cornerRadius: CGFloat = 10
            static let historyItemSpacing: CGFloat = 0
            static let historyHeaderPadding: CGFloat = 8
            static let shadowRadius: CGFloat = 5
        }
        
        enum Colors {
            static let background = Color.secondary.opacity(0.05)
            static let shadow = Color.black.opacity(0.1)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: Constants.Layout.contentSpacing) {
                VStack(spacing: Constants.Layout.vStackSpacing) {
                    Image(systemName: Constants.Images.logo)
                        .font(.system(size: Constants.Layout.logoSize))
                        .foregroundColor(.blue)
                        .padding(.bottom, Constants.Layout.logoBottomPadding)
                    
                    Text(Constants.Keys.title.localized)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(Constants.Keys.subtitle.localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, Constants.Layout.topPadding)
                
                VStack(spacing: Constants.Layout.searchBarSpacing) {
                    SearchBarView(
                        text: $viewModel.username,
                        placeholder: Constants.Keys.searchPlaceholder.localized,
                        onSubmit: viewModel.fetchUserProfile
                    )
                    .onTapGesture {
                        viewModel.isShowingSearchHistory = true
                    }
                    
                    if viewModel.isShowingSearchHistory && !viewModel.searchHistory.isEmpty {
                        searchHistoryView
                    }
                }
                .padding(.horizontal, Constants.Layout.horizontalPadding)
                .padding(.top, Constants.Layout.topPadding / 2)
                .padding(.bottom, Constants.Layout.topPadding / 2)
                
                Button {
                    viewModel.isShowingSearchHistory = false
                    viewModel.fetchUserProfile()
                } label: {
                    Text(Constants.Keys.searchButton.localized)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                                .fill(Color.blue)
                        )
                        .padding(.horizontal, Constants.Layout.buttonPadding)
                }
                .disabled(viewModel.username.isEmpty)
                .opacity(viewModel.username.isEmpty ? 0.6 : 1)
                
                if case .loading = viewModel.state {
                    LoadingView(message: Constants.Keys.loadingMessage.localized)
                        .transition(.opacity)
                }
                
                Spacer()
                
                VStack {
                    Text(Constants.Keys.footer.localized)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: Constants.Layout.vStackSpacing) {
                        TechnologyBadgeView(name: "Swift", iconName: "swift")
                        TechnologyBadgeView(name: "SwiftUI", iconName: "swift")
                        TechnologyBadgeView(name: "Async/Await", iconName: "clock.arrow.2.circlepath")
                    }
                }
                .padding(.bottom)
            }
            .animation(.easeInOut, value: viewModel.state)
            .animation(.easeInOut, value: viewModel.isShowingSearchHistory)
            .background(
                Constants.Colors.background
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
                if case .loaded(_, _) = viewModel.state {
                    UserProfileView(viewModel: viewModel)
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
                    title: Text(Constants.Keys.errorTitle.localized),
                    message: Text(alertError?.localizedDescription ?? Constants.Keys.defaultErrorMessage.localized),
                    dismissButton: .default(Text(Constants.Keys.errorDismiss.localized))
                )
            })
        }
    }
    
    private var searchHistoryView: some View {
        VStack(alignment: .leading, spacing: Constants.Layout.historyItemSpacing) {
            HStack {
                Text(Constants.Keys.recentSearches.localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(Constants.Keys.clearButton.localized) {
                    viewModel.clearSearchHistory()
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
            .padding(.top, Constants.Layout.historyHeaderPadding)
            
            Divider()
                .padding(.top, Constants.Layout.historyHeaderPadding)
            
            List {
                ForEach(viewModel.searchHistory.indices, id: \.self) { index in
                    Button {
                        viewModel.selectHistoryItem(at: index)
                    } label: {
                        HStack {
                            Image(systemName: Constants.Images.clock)
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
        .background(Constants.Colors.background)
        .cornerRadius(Constants.Layout.cornerRadius)
        .shadow(color: Constants.Colors.shadow, radius: Constants.Layout.shadowRadius)
        .padding(.horizontal)
        .transition(.opacity)
        .zIndex(1)
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
