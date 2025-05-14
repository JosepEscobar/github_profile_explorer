import SwiftUI
import RealityKit

struct ImmersiveGitHubSpace: View {
    @ObservedObject var viewModel: VisionOSUserProfileViewModel
    
    var body: some View {
        ZStack {
            // RealityView básico sin adjuntos
            RealityView { content in
                // Creamos la entidad raíz y delegamos la creación del contenido 3D al ViewModel
                let rootEntity = viewModel.createRootEntity()
                content.add(rootEntity)
            } update: { content in
                // Las actualizaciones serán manejadas por el ViewModel
                if viewModel.needsSceneUpdate {
                    content.entities.removeAll()
                    let rootEntity = viewModel.createRootEntity()
                    content.add(rootEntity)
                    viewModel.needsSceneUpdate = false
                }
            }
            
            // Panel de control como overlay normal de SwiftUI
            VStack {
                Text("Repositorios de \(viewModel.user.login)")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.linearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "person.fill")
                            Text("Seguidores: \(viewModel.user.followers)")
                        }
                        
                        HStack {
                            Image(systemName: "book.closed.fill")
                            Text("Repos: \(viewModel.user.publicRepos)")
                        }
                        
                        if let location = viewModel.user.location {
                            HStack {
                                Image(systemName: "location.fill")
                                Text(location)
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.bottom, 20)
                }
            }
            .padding(30)
        }
        .onAppear {
            // Configuramos el viewModel para recibir actualizaciones
            viewModel.configureImmersiveSpaceUpdates()
        }
    }
}

#Preview {
    ImmersiveGitHubSpace(
        viewModel: VisionOSUserProfileViewModel(
            repositories: Repository.mockArray(),
            user: User.mock()
        )
    )
} 