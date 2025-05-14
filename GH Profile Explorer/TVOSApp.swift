#if os(tvOS)
import SwiftUI

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
#endif 