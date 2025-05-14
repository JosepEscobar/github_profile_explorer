import SwiftUI

@main
struct GitHubExplorerApp: App {
    var body: some Scene {
        WindowGroup {
            #if os(iOS)
            if UIDevice.current.userInterfaceIdiom == .pad {
                iPadApp()
            } else {
                iPhoneApp()
            }
            #elseif os(macOS)
            MacOSApp()
            #elseif os(tvOS)
            TVOSApp()
            #endif
        }
    }
}

struct iPhoneApp: View {
    var body: some View {
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
}

struct iPadApp: View {
    var body: some View {
        let networkClient = NetworkClient()
        let userRepository = UserRepository(networkClient: networkClient)
        let fetchUserUseCase = FetchUserUseCase(repository: userRepository)
        let fetchRepositoriesUseCase = FetchUserRepositoriesUseCase(repository: userRepository)
        let viewModel = iPadOSUserProfileViewModel(
            fetchUserUseCase: fetchUserUseCase,
            fetchRepositoriesUseCase: fetchRepositoriesUseCase
        )
        
        return iPadOSUserProfileView(viewModel: viewModel)
    }
}

struct MacOSApp: View {
    var body: some View {
        let networkClient = NetworkClient()
        let userRepository = UserRepository(networkClient: networkClient)
        let fetchUserUseCase = FetchUserUseCase(repository: userRepository)
        let fetchRepositoriesUseCase = FetchUserRepositoriesUseCase(repository: userRepository)
        let viewModel = macOSUserProfileViewModel(
            fetchUserUseCase: fetchUserUseCase,
            fetchRepositoriesUseCase: fetchRepositoriesUseCase
        )
        
        return MacOSUserProfileView(viewModel: viewModel)
    }
}

struct TVOSApp: View {
    var body: some View {
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
} 