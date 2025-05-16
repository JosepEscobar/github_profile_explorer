#if os(visionOS)
import SwiftUI
import RealityKit

struct ImmersiveGitHubSpace: View {
    @ObservedObject var viewModel: VisionOSUserProfileViewModel
    
    var body: some View {
        ZStack {
            // RealityView básico para contenido 3D
            RealityView { content in
                // Usamos createRootEntity del ViewModel que ahora usa el factory
                let rootEntity = viewModel.createRootEntity()
                content.add(rootEntity)
            } update: { content in
                // Actualizamos la escena cuando sea necesario
                if viewModel.needsSceneUpdate {
                    content.entities.removeAll()
                    let rootEntity = viewModel.createRootEntity()
                    content.add(rootEntity)
                    viewModel.needsSceneUpdate = false
                }
            }
            
            // Panel de control como overlay normal de SwiftUI
            VStack {
                if let user = viewModel.userUI {
                    Text("Repositorios de \(user.login)")
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
                                Text("Seguidores: \(user.followers)")
                            }
                            
                            HStack {
                                Image(systemName: "book.closed.fill")
                                Text("Repos: \(user.publicRepos)")
                            }
                            
                            if let location = user.location {
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
    // Usamos un mock del ViewModel con UIModels
    let viewModel = VisionOSUserProfileViewModel(
        manageSearchHistoryUseCase: nil,
        filterRepositoriesUseCase: nil,
        openURLUseCase: nil
    )
    viewModel.userUI = UserUIModel.mock()
    viewModel.repositoriesUI = [RepositoryUIModel.mock(), RepositoryUIModel.mock()]
    
    return ImmersiveGitHubSpace(viewModel: viewModel)
}

#endif 