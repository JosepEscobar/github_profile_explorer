#if os(macOS)
import SwiftUI

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
#endif 