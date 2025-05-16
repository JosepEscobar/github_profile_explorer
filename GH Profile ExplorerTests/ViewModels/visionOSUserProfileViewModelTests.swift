import Quick
import Nimble
import Foundation
@testable import GH_Profile_Explorer

#if os(visionOS)
class VisionOSUserProfileViewModelTests: QuickSpec {
    override class func spec() {
        var viewModel: VisionOSUserProfileViewModel!
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
            
            viewModel = VisionOSUserProfileViewModel(
                fetchUserUseCase: mockFetchUserUseCase,
                fetchRepositoriesUseCase: mockFetchRepositoriesUseCase,
                manageSearchHistoryUseCase: mockSearchHistoryUseCase,
                filterRepositoriesUseCase: mockFilterRepositoriesUseCase,
                openURLUseCase: mockOpenURLUseCase
            )
        }
        
        describe("VisionOSUserProfileViewModel") {
            context("when initializing") {
                it("should load search history") {
                    // Given
                    let mockHistory = ["user1", "user2", "user3"]
                    mockSearchHistoryUseCase.mockHistory = mockHistory
                    
                    // When
                    let newViewModel = VisionOSUserProfileViewModel(
                        fetchUserUseCase: mockFetchUserUseCase,
                        fetchRepositoriesUseCase: mockFetchRepositoriesUseCase,
                        manageSearchHistoryUseCase: mockSearchHistoryUseCase,
                        filterRepositoriesUseCase: mockFilterRepositoriesUseCase,
                        openURLUseCase: mockOpenURLUseCase
                    )
                    
                    // Then
                    expect(newViewModel.searchHistory).to(equal(mockHistory))
                    expect(mockSearchHistoryUseCase.loadHistoryCalled).to(beTrue())
                    expect(mockSearchHistoryUseCase.loadHistoryPlatform).to(equal(.visionOS))
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
                    
                    // Then - first should be loading
                    expect(viewModel.state).to(equal(.loading))
                    
                    // Run the async task
                    mockFetchUserUseCase.completeExecution()
                    mockFetchRepositoriesUseCase.completeExecution()
                    
                    // Then - should be loaded with the mock data
                    expect(viewModel.state).toEventually(equal(.loaded(mockUser, mockRepositories)))
                }
                
                it("should update state to error when username is empty") {
                    // Given
                    viewModel.username = ""
                    
                    // When
                    viewModel.fetchUserProfile()
                    
                    // Then
                    if case let .error(error) = viewModel.state {
                        expect(error).to(beAKindOf(AppError.self))
                    } else {
                        fail("Expected error state but got \(viewModel.state)")
                    }
                }
                
                it("should update state to error when fetchUserUseCase fails") {
                    // Given
                    mockFetchUserUseCase.mockResult = .failure(AppError.userNotFound)
                    viewModel.username = "testuser"
                    
                    // When
                    viewModel.fetchUserProfile()
                    
                    // Then - first should be loading
                    expect(viewModel.state).to(equal(.loading))
                    
                    // Run the async task
                    mockFetchUserUseCase.completeExecution()
                    
                    // Then - should be error
                    expect(viewModel.state).toEventually(equal(.error(AppError.userNotFound)))
                }
                
                it("should add to search history on successful fetch") {
                    // Given
                    let testUsername = "testuser"
                    let mockUser = User.createMock()
                    let mockRepositories = [Repository.createMock()]
                    mockFetchUserUseCase.mockResult = .success(mockUser)
                    mockFetchRepositoriesUseCase.mockResult = .success(mockRepositories)
                    viewModel.username = testUsername
                    
                    // When
                    viewModel.fetchUserProfile()
                    
                    // Run the async task
                    mockFetchUserUseCase.completeExecution()
                    mockFetchRepositoriesUseCase.completeExecution()
                    
                    // Then
                    expect(mockSearchHistoryUseCase.addToHistoryCalled).toEventually(beTrue())
                    expect(mockSearchHistoryUseCase.addToHistoryUsername).toEventually(equal(testUsername))
                    expect(mockSearchHistoryUseCase.addToHistoryPlatform).toEventually(equal(.visionOS))
                }
            }
            
            context("when accessing computed properties") {
                it("should return userUI when state is loaded") {
                    // Given
                    let mockUser = User.createMock()
                    let mockRepositories = [Repository.createMock()]
                    
                    // When
                    viewModel.state = .loaded(mockUser, mockRepositories)
                    
                    // Then
                    expect(viewModel.userUI).toNot(beNil())
                    expect(viewModel.userUI?.login).to(equal(mockUser.login))
                }
                
                it("should return nil userUI when state is not loaded") {
                    // Given
                    viewModel.state = .initial
                    
                    // When/Then
                    expect(viewModel.userUI).to(beNil())
                }
                
                it("should return repositoriesUI when state is loaded") {
                    // Given
                    let mockUser = User.createMock()
                    let mockRepositories = [Repository.createMock()]
                    
                    // When
                    viewModel.state = .loaded(mockUser, mockRepositories)
                    
                    // Then
                    expect(viewModel.repositoriesUI.count).to(equal(mockRepositories.count))
                }
                
                it("should return empty repositoriesUI when state is not loaded") {
                    // Given
                    viewModel.state = .initial
                    
                    // When/Then
                    expect(viewModel.repositoriesUI).to(beEmpty())
                }
            }
            
            context("when filtering repositories") {
                it("should return all repositories when search query is empty") {
                    // Given
                    let mockUser = User.createMock()
                    let mockRepositories = [Repository.createMock(), Repository.createMock()]
                    viewModel.state = .loaded(mockUser, mockRepositories)
                    viewModel.searchQuery = ""
                    
                    // When/Then
                    expect(viewModel.filteredRepositoriesUI.count).to(equal(mockRepositories.count))
                }
                
                it("should return filtered repositories when search query is not empty") {
                    // Given
                    let mockUser = User.createMock()
                    let mockRepositories = [Repository.createMock(), Repository.createMock()]
                    let filteredRepositories = [mockRepositories[0]]
                    mockFilterRepositoriesUseCase.mockFilteredRepositories = filteredRepositories
                    
                    viewModel.state = .loaded(mockUser, mockRepositories)
                    viewModel.searchQuery = "test"
                    
                    // When/Then
                    expect(mockFilterRepositoriesUseCase.filterBySearchTextCalled).to(beTrue())
                    expect(mockFilterRepositoriesUseCase.filterBySearchTextSearchText).to(equal("test"))
                    expect(viewModel.filteredRepositoriesUI.count).to(equal(filteredRepositories.count))
                }
            }
            
            context("when managing search history") {
                it("should clear search history") {
                    // When
                    viewModel.clearSearchHistory()
                    
                    // Then
                    expect(mockSearchHistoryUseCase.clearHistoryCalled).to(beTrue())
                    expect(mockSearchHistoryUseCase.clearHistoryPlatform).to(equal(.visionOS))
                    expect(viewModel.searchHistory).to(beEmpty())
                }
                
                it("should remove history item at index") {
                    // Given
                    mockSearchHistoryUseCase.mockHistory = ["user1", "user2", "user3"]
                    viewModel = VisionOSUserProfileViewModel(
                        fetchUserUseCase: mockFetchUserUseCase,
                        fetchRepositoriesUseCase: mockFetchRepositoriesUseCase,
                        manageSearchHistoryUseCase: mockSearchHistoryUseCase,
                        filterRepositoriesUseCase: mockFilterRepositoriesUseCase,
                        openURLUseCase: mockOpenURLUseCase
                    )
                    
                    // When
                    viewModel.removeSearchHistoryItem(at: 1)
                    
                    // Then
                    expect(mockSearchHistoryUseCase.removeFromHistoryCalled).to(beTrue())
                    expect(mockSearchHistoryUseCase.removeFromHistoryUsername).to(equal("user2"))
                    expect(mockSearchHistoryUseCase.removeFromHistoryPlatform).to(equal(.visionOS))
                }
                
                it("should do nothing when removing invalid history index") {
                    // When
                    viewModel.removeSearchHistoryItem(at: 100) // Invalid index
                    
                    // Then
                    expect(mockSearchHistoryUseCase.removeFromHistoryCalled).to(beFalse())
                }
            }
            
            context("when setting search query") {
                it("should trim whitespace") {
                    // When
                    viewModel.setSearchQuery("  test  ")
                    
                    // Then
                    expect(viewModel.searchQuery).to(equal("test"))
                }
            }
            
            context("when opening URLs") {
                it("should set URL to open for GitHub profile") {
                    // Given
                    let mockUser = User.createMock()
                    let mockRepositories = [Repository.createMock()]
                    viewModel.state = .loaded(mockUser, mockRepositories)
                    
                    let expectedURL = URL(string: "https://github.com/testuser")!
                    mockOpenURLUseCase.mockProfileURL = expectedURL
                    
                    // When
                    viewModel.openUserInGitHub()
                    
                    // Then
                    expect(mockOpenURLUseCase.createGitHubProfileURLCalled).to(beTrue())
                    expect(mockOpenURLUseCase.createGitHubProfileURLUsername).to(equal(mockUser.login))
                    expect(viewModel.urlToOpen).to(equal(expectedURL))
                }
                
                it("should set URL to open for repository") {
                    // Given
                    let repo = Repository.createMock()
                    let repoUI = RepositoryUIModel(from: repo)
                    
                    // When
                    viewModel.openRepositoryInBrowser(repoUI)
                    
                    // Then
                    expect(viewModel.urlToOpen).to(equal(repo.htmlURL))
                }
            }
            
            context("when getting repository by id") {
                it("should return repository with matching id") {
                    // Given
                    let mockUser = User.createMock()
                    let repo1 = Repository.createMock(id: 1)
                    let repo2 = Repository.createMock(id: 2)
                    let mockRepositories = [repo1, repo2]
                    viewModel.state = .loaded(mockUser, mockRepositories)
                    
                    // When
                    let result = viewModel.getRepository(by: 2)
                    
                    // Then
                    expect(result?.id).to(equal(2))
                }
                
                it("should return nil when no repository matches id") {
                    // Given
                    let mockUser = User.createMock()
                    let repo1 = Repository.createMock(id: 1)
                    let repo2 = Repository.createMock(id: 2)
                    let mockRepositories = [repo1, repo2]
                    viewModel.state = .loaded(mockUser, mockRepositories)
                    
                    // When
                    let result = viewModel.getRepository(by: 3)
                    
                    // Then
                    expect(result).to(beNil())
                }
            }
        }
    }
}
#endif 