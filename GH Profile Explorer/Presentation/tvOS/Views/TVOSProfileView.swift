#if os(tvOS)
import SwiftUI

struct TVOSProfileView: View {
    private enum Constants {
        enum Strings {
            static let biography = "biography"
            static let followers = "followers"
            static let following = "following"
            static let repositories = "repositories"
            static let gists = "gists"
            static let topRepositories = "top_repositories"
            static let viewAll = "view_all"
            static let location = "location"
            static let profile = "profile"
            static let about = "about"
            static let statistics = "statistics"
            static let appTitle = "github_profile_explorer"
            static let backToSearch = "back_to_search"
        }
        
        enum Layout {
            static let avatarSize: CGFloat = 220
            static let avatarCornerRadius: CGFloat = 110
            static let shadowRadius: CGFloat = 20
            static let borderWidth: CGFloat = 6
            static let nameSize: CGFloat = 48
            static let statsSpacing: CGFloat = 40
            static let sectionSpacing: CGFloat = 50
            static let itemSpacing: CGFloat = 30
            static let nameSpacing: CGFloat = 12
            static let contentPadding: CGFloat = 60
            static let bioCornerRadius: CGFloat = 20
            static let bioSpacing: CGFloat = 20
            static let bioPadding: CGFloat = 30
            static let locationCornerRadius: CGFloat = 16
            static let repositoryCardWidth: CGFloat = 380
            static let repositoryCardHeight: CGFloat = 220
            static let repositoryCardSpacing: CGFloat = 30
            static let focusedScale: CGFloat = 1.05
            static let sectionHeaderPadding: CGFloat = 20
            static let sectionCornerRadius: CGFloat = 16
            static let sectionVerticalPadding: CGFloat = 30
            static let focusedShadowRadius: CGFloat = 4
            static let maxContentWidth: CGFloat = 1600
            static let statCardSize: CGFloat = 210
            static let statCardIconSize: CGFloat = 40
            static let statCardValueSize: CGFloat = 38
            static let statCardTitleSize: CGFloat = 22
            static let backButtonSize: CGFloat = 50
            static let backButtonPadding: CGFloat = 30
            static let viewAllButtonHeight: CGFloat = 60
            static let scrollViewTopPadding: CGFloat = 20
        }
        
        enum Colors {
            static let shadow = Color.blue.opacity(0.6)
            static let border = Color.white.opacity(0.5)
            static let username = Color.gray.opacity(0.8)
            static let bioBackground = Color.black.opacity(0.5)
            static let bioStroke = Color.blue.opacity(0.4)
            static let bioTitle = Color.white
            static let bioText = Color.white.opacity(0.8)
            static let locationBackground = Color.black.opacity(0.5)
            static let locationIcon = Color.blue
            static let locationText = Color.white
            static let contentBackground = Color.black.opacity(0.2)
            static let sectionTitle = Color.white.opacity(0.9)
            static let sectionBackground = Color.black.opacity(0.4)
            static let sectionBorder = Color.blue.opacity(0.3)
            static let repositoryCardBackground = Color(red: 0.08, green: 0.12, blue: 0.2)
            static let repositoryCardBorder = Color.blue.opacity(0.4)
            static let repositoryCardTitle = Color.white
            static let repositoryCardDescription = Color.gray.opacity(0.9)
            static let statCardBackground = Color(red: 0.1, green: 0.15, blue: 0.25)
            static let statCardValue = Color.white
            static let statCardTitle = Color.gray.opacity(0.8)
            static let statCardIcon = Color.blue
            static let focusRing = Color.white
            static let focusedStatCard = Color.blue.opacity(0.2)
            static let backButtonBackground = Color.black.opacity(0.5)
            static let backButtonIcon = Color.white
            static let viewAllButtonBackground = Color.blue.opacity(0.3)
            static let viewAllButtonText = Color.white
            static let languageColor = Color.gray.opacity(0.8)
            static let starIcon = Color.yellow
            static let starValue = Color.white.opacity(0.9)
        }
        
        enum Images {
            static let followers = "person.2.fill"
            static let following = "person.badge.plus"
            static let repositories = "book.closed.fill"
            static let gists = "text.alignleft"
            static let location = "location.fill"
            static let repository = "book.closed"
            static let fork = "tuningfork"
            static let star = "star.fill"
            static let stats = "chart.bar.fill"
            static let back = "chevron.backward"
            static let arrowRight = "arrow.right"
        }
    }
    
    let user: UserUIModel
    @State private var selectedRepositoryId: Int? = nil
    @FocusState private var focusedItem: FocusItem?
    @Namespace private var namespace
    @Environment(\.dismiss) private var dismiss
    @State private var scrollOffset: CGFloat = 0
    @State private var scrollViewProxy: ScrollViewProxy? = nil
    @ObservedObject var viewModel: tvOSUserProfileViewModel
    
    init(user: UserUIModel, viewModel: tvOSUserProfileViewModel) {
        self.user = user
        self.viewModel = viewModel
    }
    
    enum FocusItem: Hashable {
        case header
        case stat(Int)
        case repository(Int)
        case bioSection
        case locationSection
    }
    
    var body: some View {
        contentView
            .background(Constants.Colors.contentBackground)
            .onAppear {
                // Establecer un foco inicial en el header
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    focusedItem = .header
                }
            }
            .focusScope(namespace)
            .navigationBarBackButtonHidden(true)
            .navigationTitle("")
            .ignoresSafeArea()
            .onMoveCommand { direction in
                handleMoveCommand(direction: direction)
            }
            .onExitCommand {
                // Volver a la pantalla de búsqueda cuando se presiona menú en el mando
                viewModel.selectedSection = .search
            }
    }
    
    private func handleMoveCommand(direction: MoveCommandDirection) {
        // Scrollear automáticamente cuando el usuario navega verticalmente
        if let currentItem = focusedItem {
            switch (direction, currentItem) {
            case (.down, .header):
                withAnimation {
                    scrollViewProxy?.scrollTo("statsSection", anchor: .top)
                }
            case (.down, .stat(let index)) where index >= 2:
                if let bio = user.bio, !bio.isEmpty {
                    withAnimation {
                        scrollViewProxy?.scrollTo("bioSection", anchor: .top)
                    }
                } else if let location = user.location, !location.isEmpty {
                    withAnimation {
                        scrollViewProxy?.scrollTo("locationSection", anchor: .top)
                    }
                } else {
                    withAnimation {
                        scrollViewProxy?.scrollTo("repositoriesSection", anchor: .top)
                    }
                }
            case (.down, .bioSection):
                if let location = user.location, !location.isEmpty {
                    withAnimation {
                        scrollViewProxy?.scrollTo("locationSection", anchor: .top)
                    }
                } else {
                    withAnimation {
                        scrollViewProxy?.scrollTo("repositoriesSection", anchor: .top)
                    }
                }
            case (.down, .locationSection):
                withAnimation {
                    scrollViewProxy?.scrollTo("repositoriesSection", anchor: .top)
                }
            case (.up, .stat(let index)) where index <= 1:
                withAnimation {
                    scrollViewProxy?.scrollTo("headerSection", anchor: .top)
                }
            case (.up, .bioSection):
                withAnimation {
                    scrollViewProxy?.scrollTo("statsSection", anchor: .top)
                }
            case (.up, .locationSection):
                if let bio = user.bio, !bio.isEmpty {
                    withAnimation {
                        scrollViewProxy?.scrollTo("bioSection", anchor: .top)
                    }
                } else {
                    withAnimation {
                        scrollViewProxy?.scrollTo("statsSection", anchor: .top)
                    }
                }
            case (.up, .repository):
                if let location = user.location, !location.isEmpty {
                    withAnimation {
                        scrollViewProxy?.scrollTo("locationSection", anchor: .top)
                    }
                } else if let bio = user.bio, !bio.isEmpty {
                    withAnimation {
                        scrollViewProxy?.scrollTo("bioSection", anchor: .top)
                    }
                } else {
                    withAnimation {
                        scrollViewProxy?.scrollTo("statsSection", anchor: .top)
                    }
                }
            default:
                break
            }
        }
    }
    
    private var contentView: some View {
        ZStack(alignment: .topLeading) {
            ScrollViewReader { scrollViewReader in
                ScrollView {
                    VStack(alignment: .leading, spacing: Constants.Layout.sectionSpacing) {
                        // Profile header
                        profileHeader
                            .frame(maxWidth: .infinity, alignment: .center)
                            .focusable(true)
                            .focused($focusedItem, equals: .header)
                            .id("headerSection")
                        
                        // Stats section
                        sectionContainer(title: Constants.Strings.statistics.localized) {
                            userStats
                        }
                        .id("statsSection")
                        
                        // Bio section
                        if let bio = user.bio, !bio.isEmpty {
                            sectionContainer(title: Constants.Strings.biography.localized) {
                                bioContent(bio: bio)
                                    .focusable()
                                    .focused($focusedItem, equals: .bioSection)
                            }
                            .id("bioSection")
                        }
                        
                        // Location section
                        if let location = user.location, !location.isEmpty {
                            sectionContainer(title: Constants.Strings.location.localized) {
                                locationContent(location: location)
                                    .focusable()
                                    .focused($focusedItem, equals: .locationSection)
                            }
                            .id("locationSection")
                        }
                        
                        // Repositories section title
                        Text(Constants.Strings.repositories.localized.uppercased())
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(Constants.Colors.sectionTitle)
                            .padding(.top, Constants.Layout.sectionSpacing)
                            .padding(.horizontal, Constants.Layout.contentPadding)
                            .id("repositoriesSection")
                        
                        // Repositories content shown directly on background
                        repositoriesContent
                            .padding(.bottom, Constants.Layout.sectionSpacing)
                    }
                    .padding(.vertical, Constants.Layout.contentPadding / 2)
                    .frame(maxWidth: Constants.Layout.maxContentWidth)
                    .frame(maxWidth: .infinity)
                }
                .onAppear {
                    scrollViewProxy = scrollViewReader
                }
            }
        }
    }
    
    private func sectionContainer<Content: View>(title: String, @ViewBuilder content: @escaping () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Constants.Layout.itemSpacing) {
            Text(title.uppercased())
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Constants.Colors.sectionTitle)
                .padding(.horizontal, Constants.Layout.sectionHeaderPadding / 2)
            
            content()
                .padding(.vertical, Constants.Layout.sectionVerticalPadding)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: Constants.Layout.sectionCornerRadius)
                        .fill(Constants.Colors.sectionBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: Constants.Layout.sectionCornerRadius)
                                .stroke(Constants.Colors.sectionBorder, lineWidth: 1)
                        )
                )
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: Constants.Layout.itemSpacing) {
            AvatarImageView(
                url: user.avatarURL, 
                size: Constants.Layout.avatarSize, 
                cornerRadius: Constants.Layout.avatarCornerRadius
            )
            .shadow(
                color: Constants.Colors.shadow, 
                radius: Constants.Layout.shadowRadius
            )
            .overlay(
                Circle()
                    .stroke(Constants.Colors.border, lineWidth: Constants.Layout.borderWidth)
            )
            
            VStack(spacing: Constants.Layout.nameSpacing) {
                Text(user.name)
                    .font(.system(size: Constants.Layout.nameSize))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("@\(user.login)")
                    .font(.title)
                    .foregroundColor(Constants.Colors.username)
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 20)
    }
    
    private var userStats: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: Constants.Layout.statsSpacing) {
            ForEach(0..<4) { index in
                let (value, title, icon) = statInfo(for: index)
                focusableStatCard(
                    value: value,
                    title: title,
                    icon: icon,
                    index: index
                )
            }
        }
        .padding(.horizontal)
    }
    
    private func statInfo(for index: Int) -> (String, String, String) {
        switch index {
        case 0:
            return (user.followers, Constants.Strings.followers.localized, Constants.Images.followers)
        case 1:
            return (user.following, Constants.Strings.following.localized, Constants.Images.following)
        case 2:
            return (user.publicRepos, Constants.Strings.repositories.localized, Constants.Images.repositories)
        case 3:
            return (user.publicGists, Constants.Strings.gists.localized, Constants.Images.gists)
        default:
            return ("", "", "")
        }
    }
    
    private func focusableStatCard(value: String, title: String, icon: String, index: Int) -> some View {
        let isFocused = focusedItem == .stat(index)
        
        return Button(action: {}) {
            StatCard(
                value: value,
                title: title,
                icon: icon,
                isFocused: isFocused
            )
        }
        .buttonStyle(.tvCard)
        .focused($focusedItem, equals: .stat(index))
    }
    
    private func bioContent(bio: String) -> some View {
        Text(bio)
            .font(.title3)
            .foregroundColor(Constants.Colors.bioText)
            .lineSpacing(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Constants.Layout.bioPadding)
    }
    
    private func locationContent(location: String) -> some View {
        HStack(spacing: 15) {
            Image(systemName: Constants.Images.location)
                .foregroundColor(Constants.Colors.locationIcon)
                .font(.title2)
            
            Text(location)
                .font(.title3)
                .foregroundColor(Constants.Colors.locationText)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var repositoriesContent: some View {
        VStack(alignment: .leading, spacing: 30) {
            // Grid de repositorios
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 380), spacing: 24)
                ],
                spacing: 24
            ) {
                ForEach(viewModel.repositoriesUI) { repo in
                    repositoryCard(repository: repo)
                        .focused($focusedItem, equals: .repository(repo.id))
                }
            }
            .padding(.horizontal, Constants.Layout.contentPadding)
        }
    }
    
    private func repositoryCard(repository: RepositoryUIModel) -> some View {
        let isFocused = focusedItem == .repository(repository.id)
        
        return TVOSRepositoryCard(
            id: String(repository.id),
            name: repository.name,
            description: repository.description ?? "",
            language: repository.language,
            languageColor: repository.language != nil ? LanguageColorUtils.color(for: repository.language!) : Color.gray,
            stars: Int(repository.stars) ?? 0,
            isForked: repository.isForked,
            isFocused: isFocused,
            action: {
                selectedRepositoryId = repository.id
                // Acciones adicionales si se necesitan al seleccionar un repositorio
            }
        )
        .focused($focusedItem, equals: .repository(repository.id))
    }
}

// Mocks para el Preview
#if DEBUG
private class MockFetchUserUseCase: FetchUserUseCaseProtocol {
    func execute(username: String) async throws -> User {
        return User.mock()
    }
}

private class MockFetchUserRepositoriesUseCase: FetchUserRepositoriesUseCaseProtocol {
    func execute(username: String) async throws -> [Repository] {
        return Repository.mockArray()
    }
}
#endif

struct TVOSProfilePreview: View {
    @StateObject private var viewModel: tvOSUserProfileViewModel
    
    init() {
        let mockViewModel = tvOSUserProfileViewModel(
            fetchUserUseCase: MockFetchUserUseCase(),
            fetchRepositoriesUseCase: MockFetchUserRepositoriesUseCase()
        )
        mockViewModel.username = "apple"
        
        self._viewModel = StateObject(wrappedValue: mockViewModel)
    }
    
    var body: some View {
        NavigationView {
            TVOSProfileView(user: UserUIModel.mock(), viewModel: viewModel)
        }
    }
}

#Preview {
    TVOSProfilePreview()
}
#endif 
