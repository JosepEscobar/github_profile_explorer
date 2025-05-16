import Quick
import Nimble
import Foundation
@testable import GH_Profile_Explorer

#if os(tvOS)
class tvOSUserProfileViewModelTests: QuickSpec {
    override class func spec() {
        var viewModel: tvOSUserProfileViewModel!
        var mockFetchUserUseCase: MockFetchUserUseCase!
        var mockFetchRepositoriesUseCase: MockFetchRepositoriesUseCase!
        var mockSearchHistoryUseCase: MockSearchHistoryUseCase!
        var mockFilterRepositoriesUseCase: MockFilterRepositoriesUseCase!
        var mockOpenURLUseCase: MockOpenURLUseCase!
        
        beforeEach {
            mockFetchUserUseCase = MockFetchUserUseCase()
            mockFetchRepositoriesUseCase = MockFetchRepositoriesUseCase()
            mockSearchHistoryUseCase = MockSearchHistoryUseCase()
            mockFilterRepositoriesUseCase = MockFilterRepositoriesUseCase()
            mockOpenURLUseCase = MockOpenURLUseCase()
            
            viewModel = tvOSUserProfileViewModel(
                fetchUserUseCase: mockFetchUserUseCase,
                fetchRepositoriesUseCase: mockFetchRepositoriesUseCase,
                searchHistoryUseCase: mockSearchHistoryUseCase,
                filterRepositoriesUseCase: mockFilterRepositoriesUseCase,
                openURLUseCase: mockOpenURLUseCase
            )
        }
        
        describe("tvOSUserProfileViewModel") {
            context("when initializing") {
                it("should load search history") {
                    // Given
                    let mockHistory = ["user1", "user2", "user3"]
                    mockSearchHistoryUseCase.mockHistory = mockHistory
                    
                    // When
                    let newViewModel = tvOSUserProfileViewModel(
                        fetchUserUseCase: mockFetchUserUseCase,
                        fetchRepositoriesUseCase: mockFetchRepositoriesUseCase,
                        searchHistoryUseCase: mockSearchHistoryUseCase,
                        filterRepositoriesUseCase: mockFilterRepositoriesUseCase,
                        openURLUseCase: mockOpenURLUseCase
                    )
                    
                    // Then
                    expect(newViewModel.recentSearches).to(equal(mockHistory))
                    expect(mockSearchHistoryUseCase.loadHistoryCalled).to(beTrue())
                    expect(mockSearchHistoryUseCase.loadHistoryPlatform).to(equal(.tvOS))
                }
                
                it("should initialize with default featured users") {
                    // When
                    let newViewModel = tvOSUserProfileViewModel(
                        fetchUserUseCase: mockFetchUserUseCase,
                        fetchRepositoriesUseCase: mockFetchRepositoriesUseCase,
                        searchHistoryUseCase: mockSearchHistoryUseCase,
                        filterRepositoriesUseCase: mockFilterRepositoriesUseCase,
                        openURLUseCase: mockOpenURLUseCase
                    )
                    
                    // Then
                    expect(newViewModel.featuredUsers).toNot(beEmpty())
                    expect(newViewModel.featuredUsers).to(contain("apple"))
                    expect(newViewModel.featuredUsers).to(contain("josepescobar"))
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
                    expect(mockSearchHistoryUseCase.addToHistoryPlatform).toEventually(equal(.tvOS))
                }
                
                it("should update UI models when state changes") {
                    // Given
                    let mockUser = User.createMock()
                    let mockRepositories = [Repository.createMock()]
                    
                    // When
                    viewModel.state = .loaded(mockUser, mockRepositories)
                    
                    // Then
                    expect(viewModel.userUI).toEventuallyNot(beNil())
                    expect(viewModel.userUI?.login).toEventually(equal(mockUser.login))
                    expect(viewModel.repositoriesUI.count).toEventually(equal(mockRepositories.count))
                }
                
                it("should return error when username is empty") {
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
            
            context("when managing search history") {
                it("should clear search history") {
                    // When
                    viewModel.clearRecentSearches()
                    
                    // Then
                    expect(mockSearchHistoryUseCase.clearHistoryCalled).to(beTrue())
                    expect(mockSearchHistoryUseCase.clearHistoryPlatform).to(equal(.tvOS))
                    expect(viewModel.recentSearches).to(beEmpty())
                }
            }
            
            context("when selecting featured user") {
                it("should set username and fetch profile") {
                    // Given
                    let featuredUser = "apple"
                    let mockUser = User.createMock()
                    let mockRepositories = [Repository.createMock()]
                    mockFetchUserUseCase.mockResult = .success(mockUser)
                    mockFetchRepositoriesUseCase.mockResult = .success(mockRepositories)
                    
                    // When
                    viewModel.selectFeaturedUser(featuredUser)
                    
                    // Then
                    expect(viewModel.username).to(equal(featuredUser))
                    expect(viewModel.state).to(equal(.loading))
                    
                    // Run the async task
                    mockFetchUserUseCase.completeExecution()
                    mockFetchRepositoriesUseCase.completeExecution()
                    
                    // Should be loaded after completion
                    expect(viewModel.state).toEventually(equal(.loaded(mockUser, mockRepositories)))
                }
            }
            
            context("when getting URLs") {
                it("should get GitHub profile URL") {
                    // Given
                    let username = "testuser"
                    let expectedURL = URL(string: "https://github.com/testuser")!
                    mockOpenURLUseCase.mockProfileURL = expectedURL
                    
                    // When
                    let profileURL = viewModel.getGitHubProfileURL(for: username)
                    
                    // Then
                    expect(mockOpenURLUseCase.createGitHubProfileURLCalled).to(beTrue())
                    expect(mockOpenURLUseCase.createGitHubProfileURLUsername).to(equal(username))
                    expect(profileURL).to(equal(expectedURL))
                }
                
                it("should get repository URL") {
                    // Given
                    let mockUser = User.createMock()
                    let mockRepo = Repository.createMock()
                    let mockRepoUI = RepositoryUIModel(from: mockRepo)
                    viewModel.state = .loaded(mockUser, [mockRepo])
                    
                    // When
                    let repoURL = viewModel.getRepositoryURL(for: mockRepoUI)
                    
                    // Then
                    expect(mockOpenURLUseCase.createRepositoryURLCalled).to(beTrue())
                    expect(mockOpenURLUseCase.createRepositoryURLRepository?.id).to(equal(mockRepo.id))
                    expect(repoURL).to(equal(mockOpenURLUseCase.mockRepositoryURL))
                }
                
                it("should return nil when repository not found") {
                    // Given
                    let mockUser = User.createMock()
                    let mockRepo = Repository.createMock(id: 1)
                    let otherRepo = Repository.createMock(id: 2)
                    let otherRepoUI = RepositoryUIModel(from: otherRepo)
                    viewModel.state = .loaded(mockUser, [mockRepo])
                    
                    // When
                    let repoURL = viewModel.getRepositoryURL(for: otherRepoUI)
                    
                    // Then
                    expect(repoURL).to(beNil())
                }
            }
            
            context("when getting unique languages") {
                it("should return unique languages from repositories") {
                    // Given
                    let mockUser = User.createMock()
                    let mockRepositories = [Repository.createMock(), Repository.createMock()]
                    let languages = ["Swift", "Objective-C"]
                    mockFilterRepositoriesUseCase.mockLanguages = languages
                    
                    viewModel.state = .loaded(mockUser, mockRepositories)
                    
                    // When
                    let uniqueLanguages = viewModel.uniqueLanguages
                    
                    // Then
                    expect(mockFilterRepositoriesUseCase.extractUniqueLanguagesCalled).to(beTrue())
                    expect(mockFilterRepositoriesUseCase.extractUniqueLanguagesRepositories?.count).to(equal(mockRepositories.count))
                    expect(uniqueLanguages).to(equal(languages))
                }
                
                it("should return empty array when not in loaded state") {
                    // Given
                    viewModel.state = .initial
                    
                    // When
                    let uniqueLanguages = viewModel.uniqueLanguages
                    
                    // Then
                    expect(uniqueLanguages).to(beEmpty())
                }
            }
        }
    }
}
#endif 