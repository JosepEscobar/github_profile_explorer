import SwiftUI
import RealityKit

// Esto es solo una estructura auxiliar para el acceso a datos.
// El espacio inmersivo real se registra en la app Scene
struct ImmersiveSpaceRegistration {
    static var immersiveSpaceID = "github_space"
    
    // En lugar de ser una vista, ahora es una función estática que puede ser llamada
    static func registerImmersiveSpace() -> String {
        return immersiveSpaceID
    }
    
    // Extensión para actualizar los datos del espacio inmersivo
    static func updateImmersiveSpace(with repositories: [Repository], user: User) {
        // Este método se debe llamar cuando se activa el espacio inmersivo
        // y los datos están disponibles
        NotificationCenter.default.post(
            name: NSNotification.Name("UpdateImmersiveSpaceData"),
            object: nil,
            userInfo: [
                "repositories": repositories,
                "user": user
            ]
        )
    }
}

// Esta vista contenedora se puede usar para mostrar el espacio inmersivo en el simulador
struct ImmersiveSpacePreview: View {
    var repositories: [Repository] = Repository.mockArray()
    var user: User = User.mock()
    
    var body: some View {
        ImmersiveGitHubSpace(
            viewModel: VisionOSUserProfileViewModel(
                repositories: repositories,
                user: user
            )
        )
    }
}

#Preview {
    ImmersiveSpacePreview()
} 