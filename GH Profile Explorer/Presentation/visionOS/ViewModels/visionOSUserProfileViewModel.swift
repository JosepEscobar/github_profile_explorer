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
    
    private let userDefaults: UserDefaults
    private let historyKey = "visionSearchHistory"
    private let maxHistoryItems = 10
    
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
        var filtered = repositories
        
        // Apply text search if any
        if !searchQuery.isEmpty {
            filtered = filtered.filter { repo in
                let nameMatch = repo.name.localizedCaseInsensitiveContains(searchQuery)
                let descMatch = repo.description?.localizedCaseInsensitiveContains(searchQuery) ?? false
                return nameMatch || descMatch
            }
        }
        
        // Apply language filter if selected
        if let language = selectedLanguageFilter {
            filtered = filtered.filter { $0.language == language }
        }
        
        return filtered
    }
    
    public var languages: [String] {
        let allLanguages = repositories.compactMap { $0.language }
        return Array(Set(allLanguages)).sorted()
    }
    
    // Constructor adicional para facilitar el preview
    public convenience init(repositories: [Repository], user: User) {
        self.init(
            fetchUserUseCase: FetchUserUseCase(repository: UserRepository(networkClient: NetworkClient())),
            fetchRepositoriesUseCase: FetchUserRepositoriesUseCase(repository: UserRepository(networkClient: NetworkClient()))
        )
        self.state = .loaded(user, repositories)
    }
    
    public override init(
        fetchUserUseCase: FetchUserUseCaseProtocol,
        fetchRepositoriesUseCase: FetchUserRepositoriesUseCaseProtocol
    ) {
        self.userDefaults = UserDefaults.standard
        super.init(fetchUserUseCase: fetchUserUseCase, fetchRepositoriesUseCase: fetchRepositoriesUseCase)
        loadSearchHistory()
    }
    
    public override func fetchUserProfile() {
        guard !username.isEmpty else {
            state = .error(.unexpectedError("Username cannot be empty"))
            return
        }
        
        super.fetchUserProfile()
        addToSearchHistory(username: username)
    }
    
    private func loadSearchHistory() {
        if let history = userDefaults.stringArray(forKey: historyKey) {
            searchHistory = history
        }
    }
    
    private func addToSearchHistory(username: String) {
        if let index = searchHistory.firstIndex(of: username) {
            searchHistory.remove(at: index)
        }
        
        searchHistory.insert(username, at: 0)
        
        if searchHistory.count > maxHistoryItems {
            searchHistory = Array(searchHistory.prefix(maxHistoryItems))
        }
        
        userDefaults.set(searchHistory, forKey: historyKey)
    }
    
    public func clearSearchHistory() {
        searchHistory = []
        userDefaults.removeObject(forKey: historyKey)
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
        if let url = URL(string: "https://github.com/\(user.login)") {
            urlToOpen = url
        }
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
        switch language.lowercased() {
        case "swift":
            return .orange
        case "javascript", "typescript":
            return .yellow
        case "python":
            return .blue
        case "kotlin":
            return .purple
        case "java":
            return .red
        case "c++", "c":
            return .pink
        case "ruby":
            return .red
        case "go":
            return .cyan
        case "rust":
            return .brown
        case "html":
            return .orange
        case "css":
            return .blue
        default:
            return .gray
        }
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
    
    private func createRepositoryModels(for repositories: [Repository]) -> [ModelEntity] {
        // Mostramos hasta 10 repositorios para evitar sobrecarga
        let reposToShow = Array(repositories.prefix(min(repositories.count, 10)))
        
        var repoEntities: [ModelEntity] = []
        
        for repo in reposToShow {
            // Creamos un cubo para el repositorio, tamaño basado en estrellas
            let starMultiplier = max(0.5, min(1.5, (Float(repo.stargazersCount) / 100) + 0.5))
            let boxSize: Float = 0.3 * starMultiplier
            
            let mesh = MeshResource.generateBox(size: [boxSize, boxSize, boxSize])
            
            // Color basado en el lenguaje
            let color = colorForLanguage(repo.language)
            let material = SimpleMaterial(color: color, isMetallic: true)
            
            let repoEntity = ModelEntity(mesh: mesh, materials: [material])
            
            // Añadimos texto con el nombre del repositorio
            if let nameText = createTextModel(text: repo.name) {
                nameText.position = [0, boxSize + 0.1, 0]
                repoEntity.addChild(nameText)
            }
            
            // Añadimos estrellas para repositorios populares
            if repo.stargazersCount > 0 {
                if let starText = createTextModel(text: "★ \(repo.stargazersCount)") {
                    starText.position = [0, boxSize + 0.2, 0]
                    repoEntity.addChild(starText)
                }
            }
            
            repoEntities.append(repoEntity)
        }
        
        return repoEntities
    }
    
    private func arrangeRepositoriesInCircle(entities: [Entity], parent: Entity) {
        let count = entities.count
        let radius: Float = 2.5 // Distancia desde el centro
        
        for (index, entity) in entities.enumerated() {
            // Calculamos posición en círculo
            let angle = (Float(index) / Float(count)) * 2 * .pi
            let x = radius * sin(angle)
            let z = radius * cos(angle) - 2 // -2 para desplazar del centro
            
            // Altura varía ligeramente para interés visual
            let heightVariation: Float = Float.random(in: -0.3...0.3)
            let y: Float = 1.0 + heightVariation
            
            entity.position = [x, y, z]
            
            parent.addChild(entity)
        }
    }
    
    private func colorForLanguage(_ language: String?) -> UIColor {
        guard let language = language else { return UIColor.gray }
        
        switch language.lowercased() {
        case "swift":
            return UIColor.orange
        case "javascript", "typescript":
            return UIColor.yellow
        case "python":
            return UIColor.blue
        case "kotlin":
            return UIColor.purple
        case "java":
            return UIColor.red
        case "c++", "c":
            return UIColor.systemPink
        case "ruby":
            return UIColor.red
        case "go":
            return UIColor.cyan
        case "rust":
            return UIColor.brown
        case "html":
            return UIColor.orange
        case "css":
            return UIColor.blue
        default:
            return UIColor.lightGray
        }
    }
} 