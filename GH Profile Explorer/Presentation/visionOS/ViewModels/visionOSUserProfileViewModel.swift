#if os(visionOS)
import Foundation
import RealityKit
import SwiftUI

public final class VisionOSUserProfileViewModel: UserProfileViewModel {
    @Published public var isShowingSearchHistory: Bool = false
    @Published public var searchHistory: [String] = []
    @Published public var navigationState: ViewState?
    @Published public var isInImmersiveSpace: Bool = false
    @Published public var needsSceneUpdate: Bool = false
    @Published public var searchQuery: String = ""
    @Published public var selectedLanguageFilter: String? = nil
    @Published public var urlToOpen: URL? = nil
    
    // Use cases
    private let searchHistoryUseCase: ManageSearchHistoryUseCaseProtocol
    private let openURLUseCase: OpenURLUseCaseProtocol
    private let filterRepositoriesUseCase: FilterRepositoriesUseCaseProtocol
    
    // Referencias para la escena 3D
    public var user: User {
        if case .loaded(let user, _) = state {
            return user
        }
        return User.mock() // Valor por defecto para preview
    }
    
    public var repositories: [Repository] {
        if case .loaded(_, let repos) = state {
            return repos
        }
        return [] // Valor por defecto vacío
    }
    
    public var filteredRepositories: [Repository] {
        if !searchQuery.isEmpty || selectedLanguageFilter != nil {
            return filterRepositoriesUseCase.filterBySearchTextAndLanguage(
                repositories: repositories,
                searchText: searchQuery,
                language: selectedLanguageFilter
            )
        }
        return repositories
    }
    
    public var languages: [String] {
        return filterRepositoriesUseCase.extractUniqueLanguages(from: repositories)
    }
    
    // Constructor adicional para facilitar el preview
    public convenience init(repositories: [Repository], user: User) {
        self.init(
            fetchUserUseCase: FetchUserUseCase(repository: UserRepository(networkClient: NetworkClient())),
            fetchRepositoriesUseCase: FetchUserRepositoriesUseCase(repository: UserRepository(networkClient: NetworkClient())),
            searchHistoryUseCase: ManageSearchHistoryUseCase(),
            openURLUseCase: OpenURLUseCase(),
            filterRepositoriesUseCase: FilterRepositoriesUseCase()
        )
        self.state = .loaded(user, repositories)
    }
    
    public init(
        fetchUserUseCase: FetchUserUseCaseProtocol,
        fetchRepositoriesUseCase: FetchUserRepositoriesUseCaseProtocol,
        searchHistoryUseCase: ManageSearchHistoryUseCaseProtocol,
        openURLUseCase: OpenURLUseCaseProtocol,
        filterRepositoriesUseCase: FilterRepositoriesUseCaseProtocol
    ) {
        self.searchHistoryUseCase = searchHistoryUseCase
        self.openURLUseCase = openURLUseCase
        self.filterRepositoriesUseCase = filterRepositoriesUseCase
        
        super.init(fetchUserUseCase: fetchUserUseCase, fetchRepositoriesUseCase: fetchRepositoriesUseCase)
        loadSearchHistory()
    }
    
    // Inicializador conveniente para mantener compatibilidad
    public convenience override init(
        fetchUserUseCase: FetchUserUseCaseProtocol,
        fetchRepositoriesUseCase: FetchUserRepositoriesUseCaseProtocol
    ) {
        self.init(
            fetchUserUseCase: fetchUserUseCase,
            fetchRepositoriesUseCase: fetchRepositoriesUseCase,
            searchHistoryUseCase: ManageSearchHistoryUseCase(),
            openURLUseCase: OpenURLUseCase(),
            filterRepositoriesUseCase: FilterRepositoriesUseCase()
        )
    }
    
    public override func fetchUserProfile() {
        guard !username.isEmpty else {
            state = .error(.unexpectedError("Username cannot be empty"))
            return
        }
        
        super.fetchUserProfile()
        searchHistoryUseCase.addToSearchHistory(username: username, platform: .visionOS)
        loadSearchHistory()
    }
    
    private func loadSearchHistory() {
        searchHistory = searchHistoryUseCase.loadSearchHistory(for: .visionOS)
    }
    
    public func clearSearchHistory() {
        searchHistoryUseCase.clearSearchHistory(for: .visionOS)
        searchHistory = []
    }
    
    public func selectHistoryItem(at index: Int) {
        guard index < searchHistory.count else { return }
        username = searchHistory[index]
        isShowingSearchHistory = false
        fetchUserProfile()
    }
    
    public func toggleImmersiveMode() {
        isInImmersiveSpace.toggle()
    }
    
    public func setSearchQuery(_ query: String) {
        searchQuery = query
    }
    
    public func setLanguageFilter(_ language: String?) {
        selectedLanguageFilter = language
    }
    
    public func openUserInGitHub() {
        urlToOpen = openURLUseCase.createGitHubProfileURL(for: user.login)
    }
    
    public func openURL(_ url: URL) {
        urlToOpen = url
    }
    
    public func getRepository(by id: Int) -> Repository? {
        return repositories.first { repository in
            repository.id == id
        }
    }
    
    public func updateImmersiveSpace() {
        // Actualizamos los datos para el espacio inmersivo
        ImmersiveSpaceRegistration.updateImmersiveSpace(with: repositories, user: user)
    }
    
    public func languageColor(for language: String) -> Color {
        return LanguageColorUtils.color(for: language)
    }
    
    // MARK: - Funcionalidad 3D
    
    public func configureImmersiveSpaceUpdates() {
        // Configurar observador para actualizaciones
        Task { @MainActor in
            for await _ in NotificationCenter.default.notifications(named: NSNotification.Name("UpdateImmersiveSpaceData")) {
                self.needsSceneUpdate = true
            }
        }
    }
    
    public func createRootEntity() -> Entity {
        let rootEntity = Entity()
        
        // Añadimos luz para la escena
        let lightEntity = Entity()
        lightEntity.components[DirectionalLightComponent.self] = DirectionalLightComponent()
        rootEntity.addChild(lightEntity)
        
        // Añadimos una esfera para representar al usuario
        let avatarModel = createUserModel()
        avatarModel.position = [0, 1.2, -2]
        avatarModel.scale = [0.8, 0.8, 0.8]
        rootEntity.addChild(avatarModel)
        
        // Creamos y posicionamos los repositorios
        let repoModels = createRepositoryModels(for: repositories)
        arrangeRepositoriesInCircle(entities: repoModels, parent: rootEntity)
        
        // Añadimos texto con el nombre
        if let nameText = createTextModel(text: user.name ?? user.login) {
            nameText.position = [0, 2.0, -2]
            rootEntity.addChild(nameText)
        }
        
        return rootEntity
    }
    
    private func createTextModel(text: String) -> ModelEntity? {
        let textMesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.01,
            font: .systemFont(ofSize: 0.15),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        
        let material = SimpleMaterial(color: .white, isMetallic: false)
        let textEntity = ModelEntity(mesh: textMesh, materials: [material])
        
        return textEntity
    }
    
    private func createUserModel() -> ModelEntity {
        // Creamos una esfera simple
        let mesh = MeshResource.generateSphere(radius: 0.5)
        let material = SimpleMaterial(color: .blue, isMetallic: false)
        
        let avatarModel = ModelEntity(mesh: mesh, materials: [material])
        
        // Añadimos un efecto de brillo
        let glowMesh = MeshResource.generateSphere(radius: 0.55)
        let glowMaterial = SimpleMaterial(color: .cyan, isMetallic: true)
        let glowSphere = ModelEntity(mesh: glowMesh, materials: [glowMaterial])
        avatarModel.addChild(glowSphere)
        
        return avatarModel
    }
    
    // Crea modelos 3D para representar los repositorios del usuario
    private func createRepositoryModels(for repositories: [Repository]) -> [ModelEntity] {
        return repositories.map { repository in
            let size: Float = 0.3
            let mesh = MeshResource.generateBox(size: [size, size, size])
            
            // Usar el color del lenguaje si existe
            let color: Color = repository.language.map { LanguageColorUtils.color(for: $0) } ?? .gray
            let material = SimpleMaterial(color: UIColor(color), isMetallic: true)
            
            let entity = ModelEntity(mesh: mesh, materials: [material])
            entity.name = repository.name
            entity.components[RepositoryComponent.self] = RepositoryComponent(repository: repository)
            
            // Añadir texto con el nombre del repositorio
            if let nameText = createTextModel(text: repository.name) {
                nameText.position = [0, size + 0.1, 0]
                nameText.scale = [0.5, 0.5, 0.5]
                entity.addChild(nameText)
            }
            
            return entity
        }
    }
    
    // Organiza los repositorios en un círculo alrededor del usuario
    private func arrangeRepositoriesInCircle(entities: [ModelEntity], parent: Entity) {
        let radius: Float = 3.0
        let angleStep = (2.0 * Float.pi) / Float(entities.count)
        
        for (index, entity) in entities.enumerated() {
            let angle = Float(index) * angleStep
            let x = radius * sin(angle)
            let z = radius * cos(angle)
            entity.position = [x, 1.0, z - 2.0]
            parent.addChild(entity)
        }
    }
}

// Componente para almacenar información del repositorio
struct RepositoryComponent: Component {
    let repository: Repository
    
    init(repository: Repository) {
        self.repository = repository
    }
}

// Clase ficticia para la demostración
struct ImmersiveSpaceRegistration {
    static func updateImmersiveSpace(with repositories: [Repository], user: User) {
        // Esta función simula la actualización del espacio inmersivo
        // En una implementación real, interactuaría con RealityKit
    }
}
#endif 