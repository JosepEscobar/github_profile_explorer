# GitHub Profile Explorer

![Swift](https://img.shields.io/badge/Swift-6-orange.svg)
![Platforms](https://img.shields.io/badge/platforms-iOS%20|%20iPadOS%20|%20macOS%20|%20tvOS-blue.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-blue.svg)
![Kingfisher](https://img.shields.io/badge/Kingfisher-yellow.svg)
![Nimble](https://img.shields.io/badge/Nimble-green.svg)

**GitHub Profile Explorer** es una aplicación nativa y multiplataforma (iOS, iPadOS, macOS, visionOS y tvOS) que permite buscar perfiles de GitHub y visualizar sus datos y repositorios.

## 🚀 Características

- Búsqueda de perfiles de usuario de GitHub
- Visualización de información de usuario (nombre, foto, biografía, ubicación)
- Lista de repositorios con detalles (nombre, descripción, lenguaje)
- Interfaces específicas y optimizadas para cada plataforma
- Modo oscuro y claro
- Soporte para multitarea en iPadOS
- Funciones específicas por plataforma:
  - **macOS**: Gráfico estadístico de lenguajes, favoritos
  - **tvOS**: Usuarios destacados, navegación adaptada a control remoto
  - **iPadOS**: Layout adaptativo, SplitView optimizado
  - **iOS**: Historial de búsquedas, diseño compacto

## 📱 Capturas de pantalla

*(Aquí se incluirían capturas de pantalla de las diferentes plataformas)*

## 🧰 Tecnologías

- **Swift 6** 
- **SwiftUI** con diseños específicos por plataforma
- **Async/await** para operaciones asíncronas
- **Kingfisher** para carga y caché de imágenes
- **Quick + Nimble** para testing
- **Swift Package Manager** para gestión de módulos

## 🏗️ Arquitectura

El proyecto sigue una arquitectura **Clean MVVM Modular**:

### Capas:

- **Domain**: Entidades, casos de uso e interfaces
- **Data**: Implementaciones concretas de repositorios e integraciones
- **Presentation**: ViewModels y Vistas (específicos por plataforma)
- **SharedUI**: Componentes de UI compartidos entre plataformas

### Principios:

- **Modularidad**: Capas separadas en módulos independientes
- **Responsabilidad única**: Cada clase tiene una responsabilidad específica
- **Inversión de dependencias**: Las dependencias apuntan hacia el dominio
- **Independencia de frameworks**: El dominio no depende de frameworks externos

## 🔍 Patrones de diseño

- **Repository Pattern**: Abstrae la fuente de datos
- **Use Case Pattern**: Encapsula la lógica de negocio
- **MVVM**: Separación entre lógica y presentación
- **Dependency Injection**: Inyección de dependencias para facilitar testing
- **Factory Method**: Creación de instancias según la plataforma

## 🛠️ Requisitos

- Xcode 15.0+
- Swift 6.0+
- iOS 17.0+
- macOS 14.0+
- tvOS 17.0+

## 🧪 Tests

El proyecto incluye tests con Quick y Nimble:

- Tests unitarios para casos de uso
- Tests para repositorios
- Tests para mappers

## 🚧 Instalación y uso

1. Clonar el repositorio
2. Abrir `GH Profile Explorer.xcodeproj`
3. Seleccionar el esquema deseado (iOS, macOS, tvOS)
4. Compilar y ejecutar

## 📝 Notas de implementación

- Uso de Swift Concurrency (async/await) en lugar de Combine
- Estructura modular con Swift Package Manager
- Diseño adaptativo con GeometryReader y Layout adaptativo
- Compatibilidad con modo oscuro
- Soporte para multitarea en iPadOS

## 🧩 Detalles técnicos

1. **GitHub API**: Se utiliza la API pública de GitHub (v3)
2. **Caché de imágenes**: Kingfisher para gestión eficiente
3. **Error handling**: Sistema de errores tipados y localización
4. **Adaptabilidad**: Interfaces optimizadas por plataforma

## 🧑‍💻 Autor

Jose Escobar

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles. 