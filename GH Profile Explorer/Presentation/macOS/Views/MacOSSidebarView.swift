#if os(macOS)
import SwiftUI

enum MacOSSidebarItem: Hashable {
    case search
    case profile
    case repositories
    case stats
    case favorites
}

struct MacOSSidebarView: View {
    private enum Constants {
        enum Layout {
            static let avatarSize: CGFloat = 24
            static let minWidth: CGFloat = 200
            static let verticalPadding: CGFloat = 4
        }
        
        enum Strings {
            static let search = "search".localized
            static let searchUser = "search_user".localized
            static let currentUser = "current_user".localized
            static let repositories = "repositories".localized
            static let statistics = "statistics".localized
            static let favorites = "favorites".localized
            static let noFavorites = "no_favorites".localized
        }
        
        enum Images {
            static let search = "magnifyingglass"
            static let clear = "xmark.circle.fill"
            static let repositories = "book.closed"
            static let stats = "chart.bar"
            static let person = "person"
            static let starFill = "star.fill"
        }
        
        enum Colors {
            static let starColor = Color.yellow
            static let secondaryText = Color.secondary
        }
    }
    
    @ObservedObject var viewModel: macOSUserProfileViewModel
    @Binding var selectedSidebarItem: MacOSSidebarItem
    @State private var isShowingSearchField = false
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        List(selection: $selectedSidebarItem) {
            Section(Constants.Strings.search) {
                HStack {
                    if isShowingSearchField {
                        TextField(Constants.Strings.searchUser, text: $viewModel.username)
                            .textFieldStyle(.plain)
                            .focused($isSearchFieldFocused)
                            .onSubmit {
                                viewModel.fetchUserProfile()
                                selectedSidebarItem = .profile
                            }
                        
                        Button {
                            isShowingSearchField = false
                            isSearchFieldFocused = false
                        } label: {
                            Image(systemName: Constants.Images.clear)
                                .foregroundColor(Constants.Colors.secondaryText)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Text(Constants.Strings.searchUser)
                        
                        Spacer()
                        
                        Button {
                            showAndFocusSearchField()
                        } label: {
                            Image(systemName: Constants.Images.search)
                                .foregroundColor(Constants.Colors.secondaryText)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, Constants.Layout.verticalPadding)
                .tag(MacOSSidebarItem.search)
                .onTapGesture {
                    showAndFocusSearchField()
                }
            }
            
            if let user = viewModel.userUI {
                Section(Constants.Strings.currentUser) {
                    NavigationLink(value: MacOSSidebarItem.profile) {
                        MacOSUserRowView(user: user, isCurrent: true)
                    }
                    
                    NavigationLink(value: MacOSSidebarItem.repositories) {
                        Label(Constants.Strings.repositories, systemImage: Constants.Images.repositories)
                    }
                    
                    NavigationLink(value: MacOSSidebarItem.stats) {
                        Label(Constants.Strings.statistics, systemImage: Constants.Images.stats)
                    }
                }
            }
            
            Section(Constants.Strings.favorites) {
                if viewModel.favoriteUsernames.isEmpty {
                    Text(Constants.Strings.noFavorites)
                        .foregroundColor(Constants.Colors.secondaryText)
                        .font(.caption)
                } else {
                    ForEach(viewModel.favoriteUsernames, id: \.self) { username in
                        Button {
                            viewModel.username = username
                            viewModel.fetchUserProfile()
                            selectedSidebarItem = .profile
                        } label: {
                            HStack {
                                Label(username, systemImage: Constants.Images.person)
                                
                                Spacer()
                                
                                Button {
                                    viewModel.removeFromFavorites(username: username)
                                } label: {
                                    Image(systemName: Constants.Images.starFill)
                                        .foregroundColor(Constants.Colors.starColor)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: Constants.Layout.minWidth)
        .onChange(of: selectedSidebarItem) { oldValue, newValue in
            if newValue == .search {
                showAndFocusSearchField()
            }
        }
        .onChange(of: isShowingSearchField) { oldValue, newValue in
            if newValue {
                // Pequeño retraso para asegurar que el campo esté visible antes de darle el foco
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    isSearchFieldFocused = true
                }
            }
        }
    }
    
    private func showAndFocusSearchField() {
        isShowingSearchField = true
    }
}

struct MacOSUserRowView: View {
    private enum Constants {
        enum Layout {
            static let avatarSize: CGFloat = 24
            static let strokeWidth: CGFloat = 1
        }
        
        enum Colors {
            static let strokeColor = Color.gray.opacity(0.2)
            static let defaultForeground = Color.white
        }
        
        enum Images {
            static let defaultUser = "person.fill"
        }
    }
    
    let user: UserUIModel
    let isCurrent: Bool
    
    var body: some View {
        HStack {
            AsyncImage(url: user.avatarURL) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else if phase.error != nil {
                    Image(systemName: Constants.Images.defaultUser)
                        .foregroundColor(Constants.Colors.defaultForeground)
                } else {
                    ProgressView()
                }
            }
            .frame(width: Constants.Layout.avatarSize, height: Constants.Layout.avatarSize)
            .clipShape(Circle())
            .overlay(Circle().stroke(Constants.Colors.strokeColor, lineWidth: Constants.Layout.strokeWidth))
            
            VStack(alignment: .leading) {
                Text(user.name)
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
    MacOSSidebarView(
        viewModel: macOSUserProfileViewModel(
            fetchUserUseCase: FetchUserUseCase(repository: UserRepository(networkClient: NetworkClient())),
            fetchRepositoriesUseCase: FetchUserRepositoriesUseCase(repository: UserRepository(networkClient: NetworkClient()))
        ),
        selectedSidebarItem: .constant(.profile)
    )
}

#endif 