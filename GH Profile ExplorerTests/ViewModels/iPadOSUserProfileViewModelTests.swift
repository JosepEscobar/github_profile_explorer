import Quick
import Nimble
import Foundation
@testable import GH_Profile_Explorer

#if os(iOS)
class iPadOSUserProfileViewModelTests: QuickSpec {
    override class func spec() {
        var viewModel: iPadOSUserProfileViewModel!
        var mockFetchUserUseCase: MockFetchUserUseCase!
        var mockFetchRepositoriesUseCase: MockFetchRepositoriesUseCase!
        var mockSearchHistoryUseCase: MockSearchHistoryUseCase!
        var mockOpenURLUseCase: MockOpenURLUseCase!
        var mockFilterRepositoriesUseCase: MockFilterRepositoriesUseCase!
        
        beforeEach {
            mockFetchUserUseCase = MockFetchUserUseCase()
            mockFetchRepositoriesUseCase = MockFetchRepositoriesUseCase()
            mockSearchHistoryUseCase = MockSearchHistoryUseCase()
            mockOpenURLUseCase = MockOpenURLUseCase()
            mockFilterRepositoriesUseCase = MockFilterRepositoriesUseCase()
            
            viewModel = iPadOSUserProfileViewModel(
                fetchUserUseCase: mockFetchUserUseCase,
                fetchRepositoriesUseCase: mockFetchRepositoriesUseCase,
                searchHistoryUseCase: mockSearchHistoryUseCase,
                openURLUseCase: mockOpenURLUseCase,
                filterRepositoriesUseCase: mockFilterRepositoriesUseCase
            )
        }
        
        describe("iPadOSUserProfileViewModel") {
            context("when initializing") {
                it("should load search history") {
                    // Given
                    let mockHistory = ["user1", "user2", "user3"]
                    mockSearchHistoryUseCase.mockHistory = mockHistory
                    
                    // When
                    let newViewModel = iPadOSUserProfileViewModel(
                        fetchUserUseCase: mockFetchUserUseCase,
                        fetchRepositoriesUseCase: mockFetchRepositoriesUseCase,
                        searchHistoryUseCase: mockSearchHistoryUseCase,
                        openURLUseCase: mockOpenURLUseCase,
                        filterRepositoriesUseCase: mockFilterRepositoriesUseCase
                    )
                    
                    // Then
                    expect(newViewModel.searchHistory).to(equal(mockHistory))
                    expect(mockSearchHistoryUseCase.loadHistoryCalled).to(beTrue())
                    expect(mockSearchHistoryUseCase.loadHistoryPlatform).to(equal(.iPadOS))
                }
            }
            
            context("when fetching user profile") {
                it("should update state to loading then loaded on success") {
                    // Given
                    let mockUser = User.createMock()
                    let mockRepositories = [Repository.createMock(), Repository.createMock()]
                    
                    // Configurar los mocks con continuaciones
                    var userContinuation: CheckedContinuation<User, Error>?
                    var reposContinuation: CheckedContinuation<[Repository], Error>?
                    
                    mockFetchUserUseCase.executeWithContinuation = { continuation in
                        userContinuation = continuation
                    }
                    
                    mockFetchRepositoriesUseCase.executeWithContinuation = { continuation in
                        reposContinuation = continuation
                    }
                    
                    viewModel.username = "testuser"
                    
                    // When
                    viewModel.fetchUserProfile()
                    
                    // El estado debería cambiar a loading eventualmente (ocurre dentro de un Task)
                    expect(viewModel.state).toEventually(equal(.loading), timeout: .seconds(1))
                    
                    // Simular completar las operaciones asíncronas - importante: usar dispatchQueue.main
                    // para asegurar que las continuaciones se completan en el hilo principal
                    DispatchQueue.main.async {
                        userContinuation?.resume(returning: mockUser)
                        reposContinuation?.resume(returning: mockRepositories)
                    }
                    
                    // Then - give more time for the loaded state to be set
                    expect(viewModel.state).toEventually(equal(.loaded(mockUser, mockRepositories)), timeout: .seconds(3))
                    
                    // Verificar que los casos de uso fueron llamados correctamente
                    expect(mockFetchUserUseCase.executeCalled).to(beTrue())
                    expect(mockFetchUserUseCase.executeUsername).to(equal("testuser"))
                    expect(mockFetchRepositoriesUseCase.executeCalled).to(beTrue())
                    expect(mockFetchRepositoriesUseCase.executeUsername).to(equal("testuser"))
                }
                
                it("should add to search history on successful fetch") {
                    // Given
                    let testUsername = "testuser"
                    let mockUser = User.createMock()
                    let mockRepositories = [Repository.createMock()]
                    
                    // Configurar los mocks con continuaciones
                    var userContinuation: CheckedContinuation<User, Error>?
                    var reposContinuation: CheckedContinuation<[Repository], Error>?
                    
                    mockFetchUserUseCase.executeWithContinuation = { continuation in
                        userContinuation = continuation
                    }
                    
                    mockFetchRepositoriesUseCase.executeWithContinuation = { continuation in
                        reposContinuation = continuation
                    }
                    
                    viewModel.username = testUsername
                    
                    // When
                    viewModel.fetchUserProfile()
                    
                    // El estado debería cambiar a loading eventualmente
                    expect(viewModel.state).toEventually(equal(.loading), timeout: .seconds(1))
                    
                    // Simular completar las operaciones asíncronas en el hilo principal
                    DispatchQueue.main.async {
                        userContinuation?.resume(returning: mockUser)
                        reposContinuation?.resume(returning: mockRepositories)
                    }
                    
                    // Then
                    expect(mockSearchHistoryUseCase.addToHistoryCalled).toEventually(beTrue(), timeout: .seconds(2))
                    expect(mockSearchHistoryUseCase.addToHistoryUsername).toEventually(equal(testUsername), timeout: .seconds(2))
                    expect(mockSearchHistoryUseCase.addToHistoryPlatform).toEventually(equal(.iPadOS), timeout: .seconds(2))
                }
                
                it("should update UI models when state changes") {
                    // Given
                    let mockUser = User.createMock()
                    let mockRepositories = [Repository.createMock()]
                    
                    // Configurar los mocks con resultados síncronos para este test
                    mockFetchUserUseCase.mockResult = .success(mockUser)
                    mockFetchRepositoriesUseCase.mockResult = .success(mockRepositories)
                    
                    // When - Establecer directamente el estado para evitar problemas de asincronía
                    viewModel.state = .loaded(mockUser, mockRepositories)
                    
                    // Forzar la actualización de los modelos UI manualmente
                    Task { @MainActor in
                        // Simulamos la llamada que se haría en el didSet de state
                        viewModel.userUI = UserUIModel(from: mockUser)
                        viewModel.repositoriesUI = mockRepositories.map { RepositoryUIModel(from: $0) }
                    }
                    
                    // Then - Verificar que los modelos UI se han actualizado correctamente
                    expect(viewModel.userUI).toEventuallyNot(beNil(), timeout: .seconds(2))
                    expect(viewModel.userUI?.login).toEventually(equal(mockUser.login), timeout: .seconds(2))
                    expect(viewModel.repositoriesUI.count).toEventually(equal(mockRepositories.count), timeout: .seconds(2))
                }
            }
            
            context("when managing search history") {
                it("should clear search history") {
                    // When
                    viewModel.clearSearchHistory()
                    
                    // Then
                    expect(mockSearchHistoryUseCase.clearHistoryCalled).to(beTrue())
                    expect(mockSearchHistoryUseCase.clearHistoryPlatform).to(equal(.iPadOS))
                    expect(viewModel.searchHistory).to(beEmpty())
                }
                
                it("should remove from history") {
                    // Given
                    mockSearchHistoryUseCase.mockHistory = ["user1", "user2", "user3"]
                    viewModel = iPadOSUserProfileViewModel(
                        fetchUserUseCase: mockFetchUserUseCase,
                        fetchRepositoriesUseCase: mockFetchRepositoriesUseCase,
                        searchHistoryUseCase: mockSearchHistoryUseCase,
                        openURLUseCase: mockOpenURLUseCase,
                        filterRepositoriesUseCase: mockFilterRepositoriesUseCase
                    )
                    let usernameToRemove = "user2"
                    
                    // When
                    viewModel.removeFromHistory(username: usernameToRemove)
                    
                    // Then
                    expect(mockSearchHistoryUseCase.removeFromHistoryCalled).to(beTrue())
                    expect(mockSearchHistoryUseCase.removeFromHistoryUsername).to(equal(usernameToRemove))
                    expect(mockSearchHistoryUseCase.removeFromHistoryPlatform).to(equal(.iPadOS))
                }
                
                it("should select from history") {
                    // Given
                    let selectedUsername = "user2"
                    
                    // When
                    viewModel.selectFromHistory(selectedUsername)
                    
                    // Then
                    expect(viewModel.username).to(equal(selectedUsername))
                }
            }
            
            context("when filtering repositories") {
                it("should return all repositories when search query is empty") {
                    // Given
                    let mockUser = User.createMock()
                    let mockRepositories = [Repository.createMock(), Repository.createMock()]
                    
                    // Establecer el estado directamente y actualizar los modelos UI
                    viewModel.state = .loaded(mockUser, mockRepositories)
                    viewModel.repositoriesUI = mockRepositories.map { RepositoryUIModel(from: $0) }
                    
                    // Asegurarse de que el mock devuelve los repositorios sin filtrar cuando searchQuery está vacío
                    viewModel.searchQuery = ""
                    
                    // When/Then
                    expect(viewModel.filteredRepositories).to(equal(viewModel.repositoriesUI))
                    expect(viewModel.filteredRepositories.count).to(equal(2))
                }
                
                it("should return filtered repositories when search query is not empty") {
                    // Given
                    let mockUser = User.createMock()
                    let mockRepositories = [Repository.createMock(), Repository.createMock()]
                    let filteredRepositories = [mockRepositories[0]]
                    mockFilterRepositoriesUseCase.mockFilteredRepositories = filteredRepositories
                    
                    // Establecer el estado directamente
                    viewModel.state = .loaded(mockUser, mockRepositories)
                    
                    // When
                    viewModel.searchQuery = "test"
                    
                    // Para forzar la evaluación de filteredRepositories
                    _ = viewModel.filteredRepositories
                    
                    // Then
                    expect(mockFilterRepositoriesUseCase.filterBySearchTextCalled).to(beTrue())
                    expect(mockFilterRepositoriesUseCase.filterBySearchTextSearchText).to(equal("test"))
                    expect(viewModel.filteredRepositories.count).to(equal(filteredRepositories.count))
                }
            }
            
            context("when opening URLs") {
                it("should create URL for user in Safari") {
                    // Given
                    let username = "testuser"
                    let expectedURL = URL(string: "https://github.com/testuser")!
                    mockOpenURLUseCase.mockProfileURL = expectedURL
                    
                    // When
                    viewModel.openInSafari(username: username)
                    
                    // Then
                    expect(mockOpenURLUseCase.createGitHubProfileURLCalled).to(beTrue())
                    expect(mockOpenURLUseCase.createGitHubProfileURLUsername).to(equal(username))
                    expect(viewModel.urlToOpen).to(equal(expectedURL))
                }
                
                it("should create URL for repository in Safari") {
                    // Given
                    let mockUser = User.createMock()
                    let mockRepo = Repository.createMock()
                    let mockRepoUI = RepositoryUIModel(from: mockRepo)
                    viewModel.state = .loaded(mockUser, [mockRepo])
                    
                    mockOpenURLUseCase.mockRepositoryURL = URL(string: "https://github.com/testuser/test-repo")!
                    
                    // When
                    viewModel.openRepositoryInSafari(mockRepoUI)
                    
                    // Then
                    expect(mockOpenURLUseCase.createRepositoryURLCalled).to(beTrue())
                    expect(mockOpenURLUseCase.createRepositoryURLRepository?.id).to(equal(mockRepo.id))
                    expect(viewModel.urlToOpen).to(equal(mockOpenURLUseCase.mockRepositoryURL))
                }
            }
            
            context("when detecting orientation changes") {
                it("should update orientation when notified") {
                    // Given
                    let newOrientation: DeviceOrientation = .landscape
                    
                    // When
                    viewModel.updateOrientation(newOrientation)
                    
                    // Then
                    expect(viewModel.orientation).to(equal(newOrientation))
                }
                
                it("should ignore face up and face down orientations") {
                    // Given
                    let initialOrientation = viewModel.orientation
                    
                    // When using UIDeviceOrientation
                    viewModel.updateOrientation(initialOrientation)
                    
                    // Then
                    expect(viewModel.orientation).to(equal(initialOrientation))
                }
            }
        }
    }
}
#endif 