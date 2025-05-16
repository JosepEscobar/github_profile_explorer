import Quick
import Nimble
import Foundation
@testable import GH_Profile_Explorer

#if os(iOS) && !os(visionOS) && !targetEnvironment(macCatalyst)
class iOSUserProfileViewModelTests: QuickSpec {
    override class func spec() {
        var viewModel: iOSUserProfileViewModel!
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
            
            viewModel = iOSUserProfileViewModel(
                fetchUserUseCase: mockFetchUserUseCase,
                fetchRepositoriesUseCase: mockFetchRepositoriesUseCase,
                searchHistoryUseCase: mockSearchHistoryUseCase,
                openURLUseCase: mockOpenURLUseCase,
                filterRepositoriesUseCase: mockFilterRepositoriesUseCase
            )
        }
        
        describe("iOSUserProfileViewModel") {
            context("when initializing") {
                it("should load search history") {
                    // Given
                    let mockHistory = ["user1", "user2", "user3"]
                    mockSearchHistoryUseCase.mockHistory = mockHistory
                    
                    // When
                    let newViewModel = iOSUserProfileViewModel(
                        fetchUserUseCase: mockFetchUserUseCase,
                        fetchRepositoriesUseCase: mockFetchRepositoriesUseCase,
                        searchHistoryUseCase: mockSearchHistoryUseCase,
                        openURLUseCase: mockOpenURLUseCase,
                        filterRepositoriesUseCase: mockFilterRepositoriesUseCase
                    )
                    
                    // Then
                    expect(newViewModel.searchHistory).to(equal(mockHistory))
                    expect(mockSearchHistoryUseCase.loadHistoryCalled).to(beTrue())
                    expect(mockSearchHistoryUseCase.loadHistoryPlatform).to(equal(.iOS))
                }
            }
            
            context("when fetching user profile") {
                it("should update state to loading then loaded on success") {
                    // Given
                    let mockUser = User.createMock()
                    let mockRepositories = [Repository.createMock(), Repository.createMock()]
                    mockFetchUserUseCase.mockResult = .success(mockUser)
                    mockFetchRepositoriesUseCase.mockResult = .success(mockRepositories)
                    viewModel.username = "testuser"
                    
                    // When
                    viewModel.fetchUserProfile()
                    
                    // El estado debería cambiar a loading eventualmente (ocurre dentro de un Task)
                    expect(viewModel.state).toEventually(equal(.loading), timeout: .seconds(1))
                    
                    // Complete mocked async tasks
                    mockFetchUserUseCase.completeExecution()
                    mockFetchRepositoriesUseCase.completeExecution()
                    
                    // Then - should eventually be loaded with the mock data
                    expect(viewModel.state).toEventually(equal(.loaded(mockUser, mockRepositories)), timeout: .seconds(2))
                    
                    // Verify use case was called with correct parameters
                    expect(mockFetchUserUseCase.executeCalled).to(beTrue())
                    expect(mockFetchUserUseCase.executeUsername).to(equal("testuser"))
                    expect(mockFetchRepositoriesUseCase.executeCalled).to(beTrue())
                    expect(mockFetchRepositoriesUseCase.executeUsername).to(equal("testuser"))
                }
                
                it("should update UI models when state changes") {
                    // Given
                    let mockUser = User.createMock()
                    let mockRepositories = [Repository.createMock()]
                    mockFetchUserUseCase.mockResult = .success(mockUser)
                    mockFetchRepositoriesUseCase.mockResult = .success(mockRepositories)
                    viewModel.username = "testuser"
                    
                    // When
                    viewModel.fetchUserProfile()
                    
                    // Complete mocked async tasks
                    mockFetchUserUseCase.completeExecution()
                    mockFetchRepositoriesUseCase.completeExecution()
                    
                    // Then
                    expect(viewModel.userUI).toEventuallyNot(beNil(), timeout: .seconds(2))
                    expect(viewModel.userUI?.login).toEventually(equal(mockUser.login), timeout: .seconds(2))
                    expect(viewModel.repositoriesUI.count).toEventually(equal(mockRepositories.count), timeout: .seconds(2))
                }
                
                it("should add to search history on successful fetch") {
                    // Given
                    let mockUser = User.createMock()
                    let mockRepositories = [Repository.createMock()]
                    mockFetchUserUseCase.mockResult = .success(mockUser)
                    mockFetchRepositoriesUseCase.mockResult = .success(mockRepositories)
                    viewModel.username = "testuser"
                    
                    // When
                    viewModel.fetchUserProfile()
                    
                    // Complete mocked async tasks
                    mockFetchUserUseCase.completeExecution()
                    mockFetchRepositoriesUseCase.completeExecution()
                    
                    // Then - wait for state to be loaded
                    expect(viewModel.state).toEventually(equal(.loaded(mockUser, mockRepositories)), timeout: .seconds(2))
                    
                    // Then - verify history was added
                    expect(mockSearchHistoryUseCase.addToHistoryCalled).to(beTrue())
                    expect(mockSearchHistoryUseCase.addToHistoryUsername).to(equal("testuser"))
                    expect(mockSearchHistoryUseCase.addToHistoryPlatform).to(equal(.iOS))
                }
                
                it("should set error state when fetch fails") {
                    // Given
                    mockFetchUserUseCase.mockResult = .failure(AppError.networkError)
                    viewModel.username = "testuser"
                    
                    // When
                    viewModel.fetchUserProfile()
                    
                    // Then
                    expect {
                        if case .error = viewModel.state {
                            return true
                        }
                        return false
                    }.toEventually(beTrue(), timeout: .seconds(3))
                    
                    expect(mockFetchUserUseCase.executeCalled).to(beTrue())
                    expect(mockFetchUserUseCase.executeUsername).to(equal("testuser"))
                }
                
                it("should not fetch with empty username") {
                    // Given
                    viewModel.username = ""
                    
                    // When
                    viewModel.fetchUserProfile()
                    
                    // Then
                    if case .error(let error) = viewModel.state {
                        expect(error).to(beAKindOf(AppError.self))
                    } else {
                        fail("Expected error state but got \(viewModel.state)")
                    }
                }
            }
            
            context("when searching repositories") {
                it("should filter repositories by search text") {
                    // Given
                    let mockUser = User.createMock()
                    let mockRepositories = [Repository.createMock(), Repository.createMock()]
                    let filteredRepositories = [mockRepositories[0]]
                    
                    // Asegurarnos de que el mock devuelve los repositorios filtrados
                    mockFilterRepositoriesUseCase.mockFilteredRepositories = filteredRepositories
                    
                    // Cargar primero los datos directamente en el ViewModel
                    viewModel.state = .loaded(mockUser, mockRepositories)
                    viewModel.repositoriesUI = mockRepositories.map { RepositoryUIModel(from: $0) }
                    
                    // When
                    // Establecer el texto de búsqueda debe disparar el filtrado
                    viewModel.searchText = "test"
                    
                    // Forzar la evaluación de la propiedad computada
                    _ = viewModel.filteredRepositoriesUI
                    
                    // Then - Verificar que se llamó al método correcto en el caso de uso
                    // Nota: No podemos verificar filterBySearchTextCalled porque el método en iOSUserProfileViewModel
                    // llama a filterBySearchTextAndLanguage, no a filterBySearchText
                    expect(mockFilterRepositoriesUseCase.filterBySearchTextAndLanguageCalled).to(beTrue())
                    expect(mockFilterRepositoriesUseCase.filterSearchText).to(equal("test"))
                    expect(mockFilterRepositoriesUseCase.filterLanguage).to(beNil())
                    
                    // Verificar que ahora tenemos los repositorios filtrados
                    expect(viewModel.filteredRepositoriesUI.count).to(equal(filteredRepositories.count))
                }
            }
            
            context("when managing search history") {
                it("should clear search history") {
                    // Given
                    let mockHistory = ["user1", "user2", "user3"]
                    mockSearchHistoryUseCase.mockHistory = mockHistory
                    viewModel.searchHistory = mockHistory
                    
                    // When
                    viewModel.clearSearchHistory()
                    
                    // Then
                    expect(mockSearchHistoryUseCase.clearHistoryCalled).to(beTrue())
                    expect(mockSearchHistoryUseCase.clearHistoryPlatform).to(equal(.iOS))
                    expect(viewModel.searchHistory).to(beEmpty())
                }
            }
            
            context("when opening GitHub profile") {
                it("should create URL for current user") {
                    // Given
                    let mockUser = User.createMock()
                    let mockRepositories = [Repository.createMock()]
                    let expectedURL = URL(string: "https://github.com/testuser")!
                    mockOpenURLUseCase.mockProfileURL = expectedURL
                    mockFetchUserUseCase.mockResult = .success(mockUser)
                    mockFetchRepositoriesUseCase.mockResult = .success(mockRepositories)
                    viewModel.username = "testuser"
                    
                    // When
                    viewModel.fetchUserProfile()
                    
                    // Complete mocked async tasks
                    mockFetchUserUseCase.completeExecution()
                    mockFetchRepositoriesUseCase.completeExecution()
                    
                    // Wait for userUI to be populated
                    expect(viewModel.userUI).toEventuallyNot(beNil(), timeout: .seconds(2))
                    
                    // When
                    let profileURL = viewModel.openGitHubProfile()
                    
                    // Then
                    expect(mockOpenURLUseCase.createGitHubProfileURLCalled).to(beTrue())
                    expect(mockOpenURLUseCase.createGitHubProfileURLUsername).to(equal("testuser"))
                    expect(profileURL).to(equal(expectedURL))
                }
                
                it("should return nil when no user is loaded") {
                    // Given
                    viewModel.state = .idle
                    
                    // When
                    let profileURL = viewModel.openGitHubProfile()
                    
                    // Then
                    expect(profileURL).to(beNil())
                }
            }
        }
    }
}
#endif 