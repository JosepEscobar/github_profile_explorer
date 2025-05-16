#if os(visionOS)
import SwiftUI

struct VisionOSApp: View {
    var body: some View {
        let networkClient = NetworkClient()
        let userRepository = UserRepository(networkClient: networkClient)
        let fetchUserUseCase = FetchUserUseCase(repository: userRepository)
        let fetchRepositoriesUseCase = FetchUserRepositoriesUseCase(repository: userRepository)
        let viewModel = VisionOSUserProfileViewModel(
            fetchUserUseCase: fetchUserUseCase,
            fetchRepositoriesUseCase: fetchRepositoriesUseCase
        )
        
        return VisionOSSearchUserView(viewModel: viewModel)
    }
}
#endif 