#if os(iOS)
import SwiftUI

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
#endif 