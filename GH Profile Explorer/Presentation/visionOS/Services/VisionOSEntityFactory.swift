#if os(visionOS)
import Foundation
import RealityKit
import SwiftUI

// MARK: - Factory para crear entidades 3D en visionOS
class VisionOSEntityFactory {
    
    // Crea la entidad raíz que contiene todo el espacio inmersivo
    static func createRootEntity(user: User?, repositories: [Repository]) -> Entity {
        let rootEntity = Entity()
        
        // Añadimos luz para la escena
        let lightEntity = Entity()
        lightEntity.components[DirectionalLightComponent.self] = DirectionalLightComponent()
        rootEntity.addChild(lightEntity)
        
        guard let user = user else { return rootEntity }
        
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
    
    // Crea un modelo de texto 3D
    private static func createTextModel(text: String) -> ModelEntity? {
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
    
    // Crea una entidad para representar al usuario
    private static func createUserModel() -> ModelEntity {
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
    
    // Crea modelos 3D para representar los repositorios
    private static func createRepositoryModels(for repositories: [Repository]) -> [ModelEntity] {
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
    private static func arrangeRepositoriesInCircle(entities: [ModelEntity], parent: Entity) {
        let radius: Float = 2.0
        let totalEntities = Float(entities.count)
        
        for (index, entity) in entities.enumerated() {
            let angle = (Float(index) / totalEntities) * 2 * .pi
            let x = radius * sin(angle)
            let z = radius * cos(angle) - 2 // Ajustamos para colocar enfrente del avatar
            
            entity.position = [x, 1.0, z]
            parent.addChild(entity)
        }
    }
}

// Componente para repositorios en RealityKit
struct RepositoryComponent: Component {
    var repository: Repository
    
    init(repository: Repository) {
        self.repository = repository
    }
}
#endif 