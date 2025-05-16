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
A native and cross-platform application to explore GitHub profiles and repositories with optimized interfaces for each Apple platform.
</p>

---

## 📑 Contents

- [Features](#-features)
- [Screenshots](#-screenshots)
- [Technologies](#-technologies)
- [Architecture](#-architecture)
- [Project Structure](#-project-structure)
- [Design Patterns](#-design-patterns)
- [Requirements](#-requirements)
- [Installation and Usage](#-installation-and-usage)
- [Tests](#-tests)
- [Implementation Notes](#-implementation-notes)
- [Technical Details](#-technical-details)
- [Author](#-author)
- [Acknowledgments](#-acknowledgments)
- [License](#-license)

## 🚀 Features

- **Cross-platform**: Specific and optimized interfaces for iOS, iPadOS, macOS, visionOS, and tvOS
- **Profile Search**: Quick lookup of GitHub users
- **Data Visualization**: User information (name, photo, bio, location)
- **Repositories**: Detailed list with information (name, description, language)
- **Themes**: Support for dark and light mode
- **Platform-specific features**:
  - **iOS**: Search history, compact design optimized for mobile
  - **iPadOS**: Adaptive layout, optimized SplitView, multitasking
  - **macOS**: Language statistics chart, favorites management
  - **tvOS**: Featured users, navigation adapted to remote control
  - **visionOS**: Immersive experience with 3D elements and visual effects

## 📱 Screenshots

### 📱 iOS

<div align="center">
  <table>
    <tr>
      <td align="center"><b>Búsqueda (Modo Claro)</b></td>
      <td align="center"><b>Búsqueda (Modo Oscuro)</b></td>
    </tr>
    <tr>
      <td><img src=".github/images/iphone_search_light.png" alt="iOS Search - Light Mode" width="300"/></td>
      <td><img src=".github/images/iphone_search_dark.png" alt="iOS Search - Dark Mode" width="300"/></td>
    </tr>
    <tr>
      <td align="center"><b>Perfil (Modo Claro)</b></td>
      <td align="center"><b>Perfil (Modo Oscuro)</b></td>
    </tr>
    <tr>
      <td><img src=".github/images/iphone_profile_light.png" alt="iOS Profile - Light Mode" width="300"/></td>
      <td><img src=".github/images/iphone_profile_dark.png" alt="iOS Profile - Dark Mode" width="300"/></td>
    </tr>
  </table>
</div>

**Características destacadas:**
* Interfaz compacta optimizada para pantallas de iPhone
* Historial de búsqueda integrado para acceso rápido a perfiles consultados previamente
* Transiciones fluidas entre pantallas con animaciones naturales
* Soporte completo para modo oscuro con cambios elegantes en la paleta de colores
* Vista de perfil que presenta información esencial del desarrollador y sus repositorios más populares

### 📱 iPad

<div align="center">
  <table>
    <tr>
      <td><img src=".github/images/ipad_sidebar.png" alt="iPad Sidebar" width="700"/></td>
    </tr>
    <tr>
      <td align="center"><b>Navegación con Barra Lateral</b></td>
    </tr>
    <tr>
      <td><img src=".github/images/ipad_profile.png" alt="iPad Profile" width="700"/></td>
    </tr>
    <tr>
      <td align="center"><b>Vista de Perfil (Modo Oscuro)</b></td>
    </tr>
    <tr>
      <td><img src=".github/images/ipad_profile_light.png" alt="iPad Profile - Light Mode" width="700"/></td>
    </tr>
    <tr>
      <td align="center"><b>Vista de Perfil (Modo Claro)</b></td>
    </tr>
  </table>
</div>

**Características destacadas:**
* Diseño adaptativo que aprovecha al máximo el espacio en pantalla de iPad
* Barra lateral para navegación rápida entre perfiles y funcionalidades
* Interfaz dividida (SplitView) que permite visualizar listas y detalles simultáneamente
* Optimización para Apple Pencil con áreas interactivas mejoradas
* Soporte para multitarea con Slide Over y Split View

### 💻 macOS

<div align="center">
  <table>
    <tr>
      <td><img src=".github/images/mac_profile.png" alt="macOS Profile" width="800"/></td>
    </tr>
    <tr>
      <td align="center"><b>Vista de Perfil</b></td>
    </tr>
    <tr>
      <td><img src=".github/images/mac_repos.png" alt="macOS Repositories" width="800"/></td>
    </tr>
    <tr>
      <td align="center"><b>Lista de Repositorios</b></td>
    </tr>
    <tr>
      <td><img src=".github/images/mac_stats.png" alt="macOS Statistics" width="800"/></td>
    </tr>
    <tr>
      <td align="center"><b>Estadísticas de Lenguajes</b></td>
    </tr>
  </table>
</div>

**Características destacadas:**
* Experiencia nativa de macOS con menús, atajos de teclado y controles nativos
* Visualización avanzada de estadísticas con gráficos detallados de distribución de lenguajes
* Sistema de gestión de favoritos para acceso rápido a perfiles frecuentes
* Diseño adaptado a pantallas de alta resolución con escalado inteligente
* Soporte para drag & drop para interacciones avanzadas con contenido

### 📺 Apple TV

<div align="center">
  <table>
    <tr>
      <td><img src=".github/images/apple_tv_home.png" alt="Apple TV Home" width="800"/></td>
    </tr>
    <tr>
      <td align="center"><b>Pantalla de Inicio</b></td>
    </tr>
    <tr>
      <td><img src=".github/images/apple_tv_repos.png" alt="Apple TV Repositories" width="800"/></td>
    </tr>
    <tr>
      <td align="center"><b>Lista de Repositorios</b></td>
    </tr>
    <tr>
      <td><img src=".github/images/apple_tv_profile.png" alt="Apple TV Profile" width="800"/></td>
    </tr>
    <tr>
      <td align="center"><b>Vista de Perfil</b></td>
    </tr>
  </table>
</div>

**Características destacadas:**
* Interfaz optimizada para control remoto de Apple TV con navegación intuitiva
* Destacados con desarrolladores populares y repositorios tendencia
* Transiciones cinemáticas entre secciones para una experiencia fluida
* Diseño de 10 pies que garantiza buena legibilidad desde la distancia
* Modo de presentación para mostrar perfiles en pantallas grandes durante reuniones

### 👓 Apple Vision Pro

<div align="center">
  <table>
    <tr>
      <td><img src=".github/images/apple_vision_search.png" alt="Vision Pro Search" width="800"/></td>
    </tr>
    <tr>
      <td align="center"><b>Búsqueda Inmersiva</b></td>
    </tr>
    <tr>
      <td><img src=".github/images/apple_vision_profile.png" alt="Vision Pro Profile" width="800"/></td>
    </tr>
    <tr>
      <td align="center"><b>Vista de Perfil</b></td>
    </tr>
    <tr>
      <td><img src=".github/images/apple_vision_repo_open.png" alt="Vision Pro Repository" width="800"/></td>
    </tr>
    <tr>
      <td align="center"><b>Detalle de Repositorio</b></td>
    </tr>
  </table>
</div>

**Características destacadas:**
* Experiencia inmersiva con elementos 3D y efectos visuales avanzados
* Navegación mediante gestos y seguimiento ocular integrado
* Visualización de código con efectos de profundidad y perspectiva
* Espacios virtuales dedicados para diferentes perfiles y proyectos
* Integración con RealityKit para presentar repositorios como estructuras tridimensionales explorablesº

## 🧰 Technologies

<table>
  <tr>
    <td><b>Framework</b></td>
    <td><b>Purpose</b></td>
  </tr>
  <tr>
    <td>Swift 6</td>
    <td>Main programming language</td>
  </tr>
  <tr>
    <td>SwiftUI</td>
    <td>Declarative UI framework with platform-specific designs</td>
  </tr>
  <tr>
    <td>Async/await</td>
    <td>Modern asynchronous operations handling</td>
  </tr>
  <tr>
    <td>Kingfisher</td>
    <td>Efficient image loading and caching</td>
  </tr>
  <tr>
    <td>Quick + Nimble</td>
    <td>Testing framework with expressive syntax</td>
  </tr>
  <tr>
    <td>Swift Package Manager</td>
    <td>Dependency and module management</td>
  </tr>
  <tr>
    <td>RealityKit</td>
    <td>Framework for 3D experiences in visionOS</td>
  </tr>
</table>

## 🏗️ Architecture

The project follows a **Clean MVVM Modular** architecture that provides a clear separation of responsibilities and facilitates maintenance and scalability:

### Layers

<table>
  <tr>
    <td><b>Layer</b></td>
    <td><b>Responsibility</b></td>
  </tr>
  <tr>
    <td>Domain</td>
    <td>Business entities, use cases, and repository interfaces</td>
  </tr>
  <tr>
    <td>Data</td>
    <td>Concrete implementations of repositories, networking, and mappers</td>
  </tr>
  <tr>
    <td>Presentation</td>
    <td>Platform-specific ViewModels and Views</td>
  </tr>
  <tr>
    <td>SharedUI</td>
    <td>UI components shared across platforms</td>
  </tr>
</table>

### Principles

- **Modularity**: Layers separated into independent modules
- **Single Responsibility**: Each class has a specific responsibility
- **Dependency Inversion**: Dependencies point towards the domain
- **Framework Independence**: The domain does not depend on external frameworks

## 🏗️ Project Structure

The project organization reflects the modular architecture:

### Domain Layer

The **Domain Layer** is the core of the application, platform and framework independent:

- **Models**: Define the main data structures (`User`, `Repository`, `LanguageStat`, `AppError`)
- **Use Cases**: Implement business logic (`FetchUserUseCase`, `ManageSearchHistoryUseCase`, `FilterRepositoriesUseCase`)
- **Interfaces**: Define protocols for repositories, ensuring a clean separation between logic and data access

### Data Layer

The **Data Layer** manages access to external data:

- **Repositories**: Implement data access logic (`UserRepository`)
- **API**: Contains network infrastructure (`NetworkClient`, `Endpoint`)
- **Mappers**: Convert data between different layers (`UserMapper`, `RepositoryMapper`)

### Presentation Layer

The **Presentation Layer** is divided into platform-specific sublayers:

- **iOS**: Views and ViewModels adapted for mobile devices
- **iPadOS**: Interfaces optimized for tablets with adaptive layouts
- **macOS**: Desktop experience with advanced features
- **tvOS**: Navigation adapted to remote control and large screens
- **visionOS**: Immersive experiences with 3D elements and RealityKit

### SharedUI

Contains reusable UI components and models shared across platforms:

- **Components**: Common views like `SearchBarView`, `AvatarImageView`, and `LoadingView`
- **UIModels**: Shared presentation models
- **ViewModels**: Common presentation logic

## 🔍 Design Patterns

<table>
  <tr>
    <td><b>Pattern</b></td>
    <td><b>Implementation</b></td>
  </tr>
  <tr>
    <td>Repository Pattern</td>
    <td>Abstracts data access and hides API implementation</td>
  </tr>
  <tr>
    <td>Use Case Pattern</td>
    <td>Encapsulates business logic in independent and reusable classes</td>
  </tr>
  <tr>
    <td>MVVM</td>
    <td>Separates presentation logic (ViewModel) from visualization (View)</td>
  </tr>
  <tr>
    <td>Dependency Injection</td>
    <td>Injects dependencies instead of creating them within classes</td>
  </tr>
  <tr>
    <td>Factory Method</td>
    <td>Creates specific instances according to the platform</td>
  </tr>
</table>

## 🛠️ Requirements

- Xcode 15.0+
- Swift 6.0+
- iOS 17.0+
- iPadOS 17.0+
- macOS 14.0+
- tvOS 17.0+
- visionOS 1.0+

## 🚧 Installation and Usage

1. Clone the repository:
   ```bash
   git clone https://github.com/username/github-profile-explorer.git
   ```

2. Open the project in Xcode:
   ```bash
   open "GH Profile Explorer.xcodeproj"
   ```

3. Select the desired scheme (iOS, iPadOS, macOS, tvOS, or visionOS)

4. Build and run the application (⌘+R)

## 🧪 Tests

The project includes a complete test suite with Quick and Nimble:

- **Unit tests** for use cases and business logic, mappers, decoding, etc.


To run the tests:

1. Select the appropriate test scheme
2. Run the tests with ⌘+U

## 📝 Implementation Notes

- **Swift Concurrency**: Use of async/await for asynchronous operations instead of Combine
- **Componentization**: Small and reusable components to maintain clean code
- **Adaptive Design**: Interfaces that adapt to different screen sizes
- **Localization**: Complete localization system to support multiple languages
- **Dark Mode**: Full support for light and dark themes across all platforms

## 🧩 Technical Details

1. **GitHub API**: Uses the public GitHub API (v3)
2. **Image Cache**: Kingfisher for efficient management and asynchronous download
3. **Error handling**: Typed error system and localization for a better user experience
4. **Adaptability**: Platform-optimized interfaces leveraging unique features of each

## 🧑‍💻 Author

**Jose Escobar** - iOS Engineer

## 🙏 Acknowledgments

<div align="center">
<img src="https://img.shields.io/badge/Made%20with%20Passion%20%26%20Precision-FF9500?style=for-the-badge&logo=swift&logoColor=white" />
</div>

This project is the culmination of my 14 years of experience as an iOS Developer. It represents the knowledge, skills, and expertise I've developed throughout my professional career. Every aspect of this application—from architecture to UI design—was personally crafted by me as a demonstration of my capabilities across Apple's platforms.

While this was a solo project, I'd like to acknowledge the resources and technologies that have influenced my development approach over the years:

### Technologies and Libraries

- **[Apple Inc.](https://developer.apple.com)**: For providing SwiftUI, Swift, and the development tools that make it possible to create cross-platform applications with native interfaces for each device. Access to SwiftUI betas and technical support through WWDC, documentation, and sample code were invaluable.

- **[Kingfisher](https://github.com/onevcat/Kingfisher)**: Special thanks to Wei Wang (@onevcat) for creating and maintaining this powerful image downloading and caching library, which significantly improves performance and user experience.

- **[Quick & Nimble](https://github.com/Quick/Quick)**: Thanks to the Quick team for providing a testing framework that makes writing tests more intuitive and expressive.

- **[GitHub API](https://docs.github.com/en/rest)**: For offering a comprehensive and well-documented API that allows access to profile and repository data.

### Inspiration and Design

- Inspired by Apple's human interface design philosophy, which promotes interfaces specifically adapted to each device and form of interaction.

- The design guidelines from ["Design+Code"](https://designcode.io) were fundamental in achieving smooth transitions and a consistent user experience across all platforms.

### Community and Learning

- **[WWDC](https://developer.apple.com/wwdc25)**: Apple's Worldwide Developers Conference is the cornerstone event where the latest Apple technologies are unveiled. This essential gathering provides first-hand access to new frameworks, tools, and design principles.

- **[AppDevCon](https://appdevcon.nl)**: This Amsterdam-based conference brings together developers across mobile platforms, offering deep technical sessions and networking opportunities with European industry leaders.

- **[Swift Heroes](https://swiftheroes.com)**: Held in Turin, Italy, this event focuses exclusively on Swift development with presentations from renowned speakers sharing advanced techniques and case studies.

- **[try! Swift Tokyo](https://tryswift.jp)**: An international conference in Japan that connects Swift developers from across Asia and beyond, featuring diverse perspectives on iOS and Swift development.

- **[Deep Dish Swift](https://deepdishswift.com)**: Chicago's premier Swift conference offers in-depth technical sessions and workshops focusing on practical implementation strategies for complex iOS applications.

- **[iOSKonf](https://ioskonf.mk)**: This growing conference in North Macedonia represents the expanding reach of iOS development in Eastern Europe, with focused content on emerging mobile technologies.

- **[Swift Craft](https://swiftcraft.uk)**: A UK-based event centered on craftsmanship in Swift development, emphasizing best practices, code quality, and sustainable architecture.

- **[SwiftLeeds](https://swiftleeds.co.uk)**: This Leeds conference has quickly become a significant event in the UK Swift community, featuring practical sessions from industry veterans.

- **[Swift Connection](https://swiftconnection.io)**: Paris hosts this networking-focused event that bridges Swift developers across Europe with an emphasis on collaboration and knowledge exchange.

- **[Pragma Conference](https://pragmaconference.com)**: A long-standing Apple development conference in Bologna, Italy, known for high-quality technical content and industry networking.

- **Educational Resources**: The comprehensive materials from [Hacking with Swift](https://www.hackingwithswift.com), [Swift by Sundell](https://www.swiftbysundell.com), and [Point-Free](https://www.pointfree.co) have been instrumental in my approach to implementing modern architectures and effective design patterns.

- **Problem-Solving Networks**: [Stack Overflow](https://stackoverflow.com) and [GitHub Discussions](https://github.com/features/discussions) have provided invaluable technical solutions that have informed development decisions throughout this project.

### Productivity Tools

- **[SwiftLint](https://github.com/realm/SwiftLint)**: Ensures code quality and consistency by enforcing Swift style and conventions, significantly reducing the time spent on code reviews and standardizing the codebase.

- **[SwiftGen](https://github.com/SwiftGen/SwiftGen)**: Generates type-safe code for resources such as images, fonts, and strings, eliminating runtime errors and improving IDE autocomplete support.

- **[XCMetrics](https://github.com/spotify/XCMetrics)**: Collects and analyzes build metrics to optimize compilation times and identify performance bottlenecks in the development workflow.

- **[OpenAI](https://openai.com)**: Leverages advanced AI models for code generation, documentation assistance, and problem-solving, dramatically accelerating development speed and enabling creative solutions to complex challenges.

- **[Anthropic](https://anthropic.com)**: Utilizes Claude AI for nuanced code reviews, architecture planning, and technical documentation, with a focus on creating reliable and maintainable code patterns.

- **[Cursor](https://cursor.sh)**: An AI-enhanced code editor that streamlines development with intelligent code completion, refactoring suggestions, and contextual documentation, significantly enhancing productivity across the entire development lifecycle.

### Resources and References

<div align="center">
<img src="https://img.shields.io/badge/Standing%20on%20the%20Shoulders%20of%20Giants-5A45FF?style=for-the-badge&logo=github&logoColor=white" />
</div>

- **Technical Articles**: Publications from [objc.io](https://www.objc.io), [NSHipster](https://nshipster.com), and [Swift with Majid](https://swiftwithmajid.com) were invaluable resources for implementing advanced SwiftUI patterns and architecture.

- **Podcasts**: [Swift by Sundell](https://www.swiftbysundell.com/podcast/), [Swift Unwrapped](https://spec.fm/podcasts/swift-unwrapped), and [Inside iOS Dev](https://insideiosdev.com) provided deep insights into development best practices.

- **Open Source Projects**: Architectural inspiration came from studying projects.

- **Books**: "Advanced iOS App Architecture" by Soroush Khanlou and "Swift in Depth" by Tjeerd in 't Veen were crucial references for architectural decisions.

### Special Thanks

A special acknowledgment to the SwiftUI developer community whose work I've followed over the years. The knowledge shared through blogs, videos, and open-source repositories has been instrumental in shaping my own development approach.
<br>
<br>

<div align="center">
<img src="https://img.shields.io/badge/Code%20is%20Poetry%2C%20UI%20is%20Art-007AFF?style=for-the-badge&logo=apple&logoColor=white" />
</div>
<br>
Finally, this project reflects the culmination of skills acquired throughout my 14-year journey as an iOS developer. From the early days of UIKit to the modern SwiftUI framework, this application demonstrates my ability to leverage Apple's technologies to create seamless, cross-platform experiences on iOS, iPadOS, macOS, tvOS, and visionOS.

## 📄 License

This project is under the MIT License. See the `LICENSE` file for more details. 