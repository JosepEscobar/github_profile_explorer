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

*(Screenshots of the different platforms would be included here)*

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

- **Unit tests** for use cases and business logic
- **Integration tests** for repositories and data layer
- **Mapper tests** to validate data transformation

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

## 📄 License

This project is under the MIT License. See the `LICENSE` file for more details. 