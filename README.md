# GitHub Profile Explorer

<div align="center">

![SwiftUI](https://img.shields.io/badge/SwiftUI-blue?style=for-the-badge&logo=swift&logoColor=white)
![Swift 6](https://img.shields.io/badge/Swift-6-F05138?style=for-the-badge&logo=swift&logoColor=white)
![Platforms](https://img.shields.io/badge/Platforms-iOS%20|%20iPadOS%20|%20macOS%20|%20tvOS%20|%20visionOS-informational?style=for-the-badge&logo=apple&logoColor=white)
![Kingfisher](https://img.shields.io/badge/Kingfisher-5.15.7-yellow?style=for-the-badge)
![Testing](https://img.shields.io/badge/Testing-Quick%20|%20Nimble-green?style=for-the-badge)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20MVVM-purple?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)

</div>

<p align="center">
Una aplicación nativa y multiplataforma para explorar perfiles y repositorios de GitHub con interfaces optimizadas para cada plataforma Apple.
</p>

---

## 📑 Contenido

- [Características](#-características)
- [Capturas de Pantalla](#-capturas-de-pantalla)
- [Tecnologías](#-tecnologías)
- [Arquitectura](#-arquitectura)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Patrones de Diseño](#-patrones-de-diseño)
- [Requisitos](#-requisitos)
- [Instalación y Uso](#-instalación-y-uso)
- [Tests](#-tests)
- [Notas de Implementación](#-notas-de-implementación)
- [Detalles Técnicos](#-detalles-técnicos)
- [Autor](#-autor)
- [Licencia](#-licencia)

## 🚀 Características

- **Multiplataforma**: Interfaces específicas y optimizadas para iOS, iPadOS, macOS, visionOS y tvOS
- **Búsqueda de perfiles**: Consulta rápida de usuarios de GitHub
- **Visualización de datos**: Información de usuario (nombre, foto, biografía, ubicación)
- **Repositorios**: Lista detallada con información (nombre, descripción, lenguaje)
- **Temas**: Soporte para modo oscuro y claro
- **Características específicas por plataforma**:
  - **iOS**: Historial de búsquedas, diseño compacto optimizado para móvil
  - **iPadOS**: Layout adaptativo, SplitView optimizado, multitarea
  - **macOS**: Gráfico estadístico de lenguajes, gestión de favoritos
  - **tvOS**: Usuarios destacados, navegación adaptada a control remoto
  - **visionOS**: Experiencia inmersiva con elementos 3D y efectos visuales

## 📱 Capturas de Pantalla

*(Aquí se incluirían capturas de pantalla de las diferentes plataformas)*

## 🧰 Tecnologías

<table>
  <tr>
    <td><b>Framework</b></td>
    <td><b>Propósito</b></td>
  </tr>
  <tr>
    <td>Swift 6</td>
    <td>Lenguaje de programación principal</td>
  </tr>
  <tr>
    <td>SwiftUI</td>
    <td>Framework de UI declarativo con diseños específicos por plataforma</td>
  </tr>
  <tr>
    <td>Async/await</td>
    <td>Manejo moderno de operaciones asíncronas</td>
  </tr>
  <tr>
    <td>Kingfisher</td>
    <td>Carga y caché eficiente de imágenes</td>
  </tr>
  <tr>
    <td>Quick + Nimble</td>
    <td>Framework para testing con sintaxis expresiva</td>
  </tr>
  <tr>
    <td>Swift Package Manager</td>
    <td>Gestión de dependencias y módulos</td>
  </tr>
  <tr>
    <td>RealityKit</td>
    <td>Framework para experiencias 3D en visionOS</td>
  </tr>
</table>

## 🏗️ Arquitectura

El proyecto sigue una arquitectura **Clean MVVM Modular** que proporciona una clara separación de responsabilidades y facilita el mantenimiento y escalabilidad:

### Capas

<table>
  <tr>
    <td><b>Capa</b></td>
    <td><b>Responsabilidad</b></td>
  </tr>
  <tr>
    <td>Domain</td>
    <td>Entidades de negocio, casos de uso e interfaces de repository</td>
  </tr>
  <tr>
    <td>Data</td>
    <td>Implementaciones concretas de repositorios, networking y mappers</td>
  </tr>
  <tr>
    <td>Presentation</td>
    <td>ViewModels y Vistas específicos para cada plataforma</td>
  </tr>
  <tr>
    <td>SharedUI</td>
    <td>Componentes de UI compartidos entre plataformas</td>
  </tr>
</table>

### Principios

- **Modularidad**: Capas separadas en módulos independientes
- **Responsabilidad única**: Cada clase tiene una responsabilidad específica
- **Inversión de dependencias**: Las dependencias apuntan hacia el dominio
- **Independencia de frameworks**: El dominio no depende de frameworks externos

## 🏗️ Estructura del Proyecto

La organización del proyecto refleja la arquitectura modular:

### Capa de Dominio

La **Capa de Dominio** es el núcleo de la aplicación, independiente de la plataforma y frameworks:

- **Modelos**: Definen las estructuras de datos principales (`User`, `Repository`, `LanguageStat`, `AppError`)
- **Casos de Uso**: Implementan la lógica de negocio (`FetchUserUseCase`, `ManageSearchHistoryUseCase`, `FilterRepositoriesUseCase`)
- **Interfaces**: Definen protocolos para repositorios, asegurando una separación limpia entre la lógica y el acceso a datos

### Capa de Datos

La **Capa de Datos** gestiona el acceso a datos externos:

- **Repositorios**: Implementan la lógica de acceso a datos (`UserRepository`)
- **API**: Contiene infraestructura de red (`NetworkClient`, `Endpoint`)
- **Mappers**: Convierten datos entre diferentes capas (`UserMapper`, `RepositoryMapper`)

### Capa de Presentación

La **Capa de Presentación** está dividida en subcapas específicas para cada plataforma:

- **iOS**: Vistas y ViewModels adaptados para dispositivos móviles
- **iPadOS**: Interfaces optimizadas para tablet con layouts adaptativos
- **macOS**: Experiencia de escritorio con funcionalidades avanzadas
- **tvOS**: Navegación adaptada a control remoto y pantallas grandes
- **visionOS**: Experiencias inmersivas con elementos 3D y RealityKit

### SharedUI

Contiene componentes de UI reutilizables y modelos que se comparten entre plataformas:

- **Components**: Vistas comunes como `SearchBarView`, `AvatarImageView` y `LoadingView`
- **UIModels**: Modelos de presentación compartidos
- **ViewModels**: Lógica de presentación común

## 🔍 Patrones de Diseño

<table>
  <tr>
    <td><b>Patrón</b></td>
    <td><b>Implementación</b></td>
  </tr>
  <tr>
    <td>Repository Pattern</td>
    <td>Abstrae el acceso a datos y oculta la implementación de API</td>
  </tr>
  <tr>
    <td>Use Case Pattern</td>
    <td>Encapsula la lógica de negocio en clases independientes y reutilizables</td>
  </tr>
  <tr>
    <td>MVVM</td>
    <td>Separa la lógica de presentación (ViewModel) de la visualización (View)</td>
  </tr>
  <tr>
    <td>Dependency Injection</td>
    <td>Inyecta dependencias en lugar de crearlas dentro de las clases</td>
  </tr>
  <tr>
    <td>Factory Method</td>
    <td>Crea instancias específicas según la plataforma</td>
  </tr>
</table>

## 🛠️ Requisitos

- Xcode 15.0+
- Swift 6.0+
- iOS 17.0+
- iPadOS 17.0+
- macOS 14.0+
- tvOS 17.0+
- visionOS 1.0+

## 🚧 Instalación y Uso

1. Clona el repositorio:
   ```bash
   git clone https://github.com/username/github-profile-explorer.git
   ```

2. Abre el proyecto en Xcode:
   ```bash
   open "GH Profile Explorer.xcodeproj"
   ```

3. Selecciona el esquema deseado (iOS, iPadOS, macOS, tvOS o visionOS)

4. Compila y ejecuta la aplicación (⌘+R)

## 🧪 Tests

El proyecto incluye una suite completa de tests con Quick y Nimble:

- **Tests unitarios** para casos de uso y lógica de negocio
- **Tests de integración** para repositorios y capa de datos
- **Tests de mappers** para validar la transformación de datos

Para ejecutar los tests:

1. Selecciona el esquema de test adecuado
2. Ejecuta los tests con ⌘+U

## 📝 Notas de Implementación

- **Swift Concurrency**: Uso de async/await para operaciones asíncronas en lugar de Combine
- **Componentización**: Componentes pequeños y reutilizables para mantener un código limpio
- **Diseño adaptativo**: Interfaces que se adaptan a diferentes tamaños de pantalla
- **Localización**: Sistema completo de localización para soportar múltiples idiomas
- **Modo oscuro**: Soporte completo para temas claro y oscuro en todas las plataformas

## 🧩 Detalles Técnicos

1. **GitHub API**: Se utiliza la API pública de GitHub (v3)
2. **Caché de imágenes**: Kingfisher para gestión eficiente y descarga asíncrona
3. **Error handling**: Sistema de errores tipados y localización para una mejor experiencia de usuario
4. **Adaptabilidad**: Interfaces optimizadas por plataforma aprovechando características únicas de cada una

## 🧑‍💻 Autor

**Jose Escobar** - iOS Engineer

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles. 