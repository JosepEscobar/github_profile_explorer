#if os(visionOS)
import SwiftUI
import Kingfisher
import RealityKit

// Componente específico para iconos 3D en visionOS
struct IconWith3DEffect: View {
    let systemName: String
    let color: Color
    let size: CGFloat
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            // Fondo con efecto 3D
            Circle()
                .fill(color.opacity(0.1))
                .frame(width: size * 1.2, height: size * 1.2)
                .shadow(color: color.opacity(0.4), radius: 15)
                .rotation3DEffect(
                    .degrees(rotationAngle),
                    axis: (x: 0, y: 1, z: 0)
                )
                .onAppear {
                    withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                        rotationAngle = 15
                    }
                }
            
            // Icono estático
            Image(systemName: systemName)
                .font(.system(size: size))
                .foregroundColor(color)
                .symbolEffect(.pulse)
        }
        .frame(height: size * 1.5)
    }
}

struct VisionOSSearchUserView: View {
    @StateObject var viewModel: VisionOSUserProfileViewModel
    @State private var showAlert = false
    @State private var alertError: AppError?
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.black.opacity(0.1)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Logo with 3D effect
                    VStack(spacing: 12) {
                        IconWith3DEffect(
                            systemName: "person.fill.viewfinder", 
                            color: .blue, 
                            size: 80
                        )
                        
                        Text("GitHub Profile Explorer")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.linearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                        
                        Text("Busca perfiles de desarrolladores en GitHub")
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    .hoverEffect(.lift)
                    
                    // Search Bar - Floating effect
                    VStack(spacing: 16) {
                        SearchBarView(
                            text: $viewModel.username,
                            placeholder: "Buscar usuario",
                            onSubmit: viewModel.fetchUserProfile
                        )
                        .frame(width: 400)
                    }
                    .padding(.vertical, 20)
                    
                    // Search Button with 3D effect
                    Button {
                        viewModel.fetchUserProfile()
                    } label: {
                        Text("Buscar")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .frame(width: 250, height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        .linearGradient(
                                            colors: [.blue, .purple.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.username.isEmpty)
                    .opacity(viewModel.username.isEmpty ? 0.6 : 1)
                    .hoverEffect(.highlight)
                    
                    if case .loading = viewModel.state {
                        LoadingView(message: "Buscando usuario...")
                            .transition(.opacity)
                    }
                    
                    Spacer()
                    
                    // Promotional footer
                    VStack {
                        Text("Desarrollado con 💙 usando")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 16) {
                            VisionOSTechnologyBadgeView(name: "Swift", iconName: "swift")
                            VisionOSTechnologyBadgeView(name: "SwiftUI", iconName: "swift")
                            VisionOSTechnologyBadgeView(name: "visionOS", iconName: "eye")
                        }
                    }
                    .padding(.bottom, 30)
                }
                .padding()
            }
            .navigationDestination(
                isPresented: Binding<Bool>(
                    get: { 
                        if case .loaded = viewModel.state {
                            return true
                        }
                        return false
                    },
                    set: { _ in }
                )
            ) {
                if case .loaded = viewModel.state {
                    VisionOSUserProfileView(viewModel: viewModel)
                }
            }
            .task {
                // Observar cambios en el estado
                for await _ in viewModel.$state.values {
                    if case let .error(error) = viewModel.state {
                        alertError = error
                        showAlert = true
                    }
                }
            }
            .alert(isPresented: $showAlert, content: {
                Alert(
                    title: Text("Error"),
                    message: Text(alertError?.localizedDescription ?? "An error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            })
        }
    }
}

struct VisionOSTechnologyBadgeView: View {
    let name: String
    let iconName: String
    
    var body: some View {
        HStack(spacing: 8) {
            // Usar una versión más robusta para los iconos de tecnología
            Image(systemName: iconName)
                .font(.headline)
                .foregroundColor(.primary)
                .frame(width: 24, height: 24)
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 32, height: 32)
                )
                
            Text(name)
                .font(.headline)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
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

#endif 
