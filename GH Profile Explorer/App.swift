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
            #elseif os(visionOS)
            VisionOSApp()
            #endif
        }
        
        #if os(visionOS)
        // Registro correcto del espacio inmersivo para visionOS
        ImmersiveSpace(id: ImmersiveSpaceRegistration.immersiveSpaceID) {
            ImmersiveGitHubSpace(
                viewModel: VisionOSUserProfileViewModel(
                    repositories: Repository.mockArray(),
                    user: User.mock()
                )
            )
        }
        #endif
    }
}
