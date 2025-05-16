import Quick
import Nimble
import Foundation
@testable import GH_Profile_Explorer

#if os(macOS)
class macOSUserProfileViewModelTests: QuickSpec {
    override class func spec() {
        var viewModel: macOSUserProfileViewModel!
        var mockFetchUserUseCase: MockFetchUserUseCase!
        var mockFetchRepositoriesUseCase: MockFetchRepositoriesUseCase!
        var mockCalculateLanguageStatsUseCase: MockCalculateLanguageStatsUseCase!
        var mockSearchHistoryUseCase: MockSearchHistoryUseCase!
        var mockFavoritesUseCase: MockFavoritesUseCase!
        var mockOpenURLUseCase: MockOpenURLUseCase!
        var mockFilterRepositoriesUseCase: MockFilterRepositoriesUseCase!
        
        beforeEach {
            mockFetchUserUseCase = MockFetchUserUseCase()
            mockFetchRepositoriesUseCase = MockFetchRepositoriesUseCase()
            mockCalculateLanguageStatsUseCase = MockCalculateLanguageStatsUseCase()
            mockSearchHistoryUseCase = MockSearchHistoryUseCase()
            mockFavoritesUseCase = MockFavoritesUseCase()
            mockOpenURLUseCase = MockOpenURLUseCase()
            mockFilterRepositoriesUseCase = MockFilterRepositoriesUseCase()
            
            viewModel = macOSUserProfileViewModel(
                fetchUserUseCase: mockFetchUserUseCase,
                fetchRepositoriesUseCase: mockFetchRepositoriesUseCase,
                calculateLanguageStatsUseCase: mockCalculateLanguageStatsUseCase,
                searchHistoryUseCase: mockSearchHistoryUseCase,
                favoritesUseCase: mockFavoritesUseCase,
                openURLUseCase: mockOpenURLUseCase,
                filterRepositoriesUseCase: mockFilterRepositoriesUseCase
            )
        }
        
        describe("macOSUserProfileViewModel") {
            context("when loading initial data") {
                it("should load search history and favorites") {
                    // Given
                    let mockHistory = ["user1", "user2", "user3"]
                    let mockFavorites = ["user1", "user4"]
                    mockSearchHistoryUseCase.mockHistory = mockHistory
                    mockFavoritesUseCase.mockFavorites = mockFavorites
                    
                    // When
                    let newViewModel = macOSUserProfileViewModel(
                        fetchUserUseCase: mockFetchUserUseCase,
                        fetchRepositoriesUseCase: mockFetchRepositoriesUseCase,
                        calculateLanguageStatsUseCase: mockCalculateLanguageStatsUseCase,
                        searchHistoryUseCase: mockSearchHistoryUseCase,
                        favoritesUseCase: mockFavoritesUseCase,
                        openURLUseCase: mockOpenURLUseCase,
                        filterRepositoriesUseCase: mockFilterRepositoriesUseCase
                    )
                    
                    // Then
                    expect(newViewModel.searchHistory).to(equal(mockHistory))
                    expect(newViewModel.favoriteUsernames).to(equal(mockFavorites))
                    expect(mockSearchHistoryUseCase.loadHistoryCalled).to(beTrue())
                    expect(mockSearchHistoryUseCase.loadHistoryPlatform).to(equal(.macOS))
                    expect(mockFavoritesUseCase.loadFavoritesCalled).to(beTrue())
                }
            }
            
            context("when handling loaded state") {
                it("should update UI models and calculate language stats") {
                    // Given
                    let mockUser = User.createMock()
                    let mockRepositories = [Repository.createMock(), Repository.createMock()]
                    let mockLanguageStats = [LanguageStat(language: "Swift", count: 2)]
                    mockCalculateLanguageStatsUseCase.mockStats = mockLanguageStats
                    
                    // When
                    viewModel.handleLoadedState(user: mockUser, repositories: mockRepositories)
                    
                    // Then
                    expect(viewModel.userUI).toNot(beNil())
                    expect(viewModel.userUI?.login).to(equal(mockUser.login))
                    expect(viewModel.repositoriesUI.count).to(equal(mockRepositories.count))
                    expect(viewModel.languageStats.count).to(equal(mockLanguageStats.count))
                    expect(viewModel.languageStats[0].language).to(equal(mockLanguageStats[0].language))
                    expect(viewModel.languageStats[0].count).to(equal(mockLanguageStats[0].count))
                    expect(mockCalculateLanguageStatsUseCase.executeForCalled).to(beTrue())
                    expect(mockCalculateLanguageStatsUseCase.executeForRepositories?.count).to(equal(mockRepositories.count))
                    expect(mockSearchHistoryUseCase.addToHistoryCalled).to(beTrue())
                    expect(mockSearchHistoryUseCase.addToHistoryUsername).to(equal(mockUser.login))
                    expect(mockSearchHistoryUseCase.addToHistoryPlatform).to(equal(.macOS))
                }
            }
            
            context("when filtering repositories") {
                it("should return all repositories when search query is empty") {
                    // Given
                    let mockUser = User.createMock()
                    let mockRepositories = [Repository.createMock(), Repository.createMock()]
                    viewModel.userUI = UserUIModel(from: mockUser)
                    viewModel.repositoriesUI = mockRepositories.map { RepositoryUIModel(from: $0) }
                    viewModel.state = .loaded(mockUser, mockRepositories)
                    viewModel.searchQuery = ""
                    
                    // When/Then
                    expect(viewModel.filteredRepositories.count).to(equal(mockRepositories.count))
                }
                
                it("should return filtered repositories when search query is not empty") {
                    // Given
                    let mockUser = User.createMock()
                    let mockRepositories = [Repository.createMock(), Repository.createMock()]
                    let filteredRepositories = [mockRepositories[0]]
                    mockFilterRepositoriesUseCase.mockFilteredRepositories = filteredRepositories
                    
                    // Es importante establecer el estado antes de establecer searchQuery
                    viewModel.state = .loaded(mockUser, mockRepositories)
                    
                    // When
                    viewModel.searchQuery = "test"
                    
                    // Forzar la evaluación de la propiedad computada filteredRepositories
                    let result = viewModel.filteredRepositories
                    
                    // Then
                    expect(mockFilterRepositoriesUseCase.filterBySearchTextCalled).to(beTrue())
                    expect(mockFilterRepositoriesUseCase.filterBySearchTextSearchText).to(equal("test"))
                    expect(result.count).to(equal(filteredRepositories.count))
                }
            }
            
            context("when managing search history") {
                it("should clear search history") {
                    // When
                    viewModel.clearSearchHistory()
                    
                    // Then
                    expect(mockSearchHistoryUseCase.clearHistoryCalled).to(beTrue())
                    expect(mockSearchHistoryUseCase.clearHistoryPlatform).to(equal(.macOS))
                    expect(viewModel.searchHistory).to(beEmpty())
                }
                
                it("should select from history") {
                    // Given
                    let selectedUsername = "user2"
                    
                    // When
                    viewModel.selectFromHistory(username: selectedUsername)
                    
                    // Then
                    expect(viewModel.username).to(equal(selectedUsername))
                }
                
                it("should remove from history") {
                    // Given
                    mockSearchHistoryUseCase.mockHistory = ["user1", "user2", "user3"]
                    let usernameToRemove = "user2"
                    
                    // When
                    viewModel.removeFromHistory(username: usernameToRemove)
                    
                    // Then
                    expect(mockSearchHistoryUseCase.removeFromHistoryCalled).to(beTrue())
                    expect(mockSearchHistoryUseCase.removeFromHistoryUsername).to(equal(usernameToRemove))
                    expect(mockSearchHistoryUseCase.removeFromHistoryPlatform).to(equal(.macOS))
                }
            }
            
            context("when managing favorites") {
                it("should add to favorites") {
                    // Given
                    let username = "testuser"
                    
                    // When
                    viewModel.addToFavorites(username: username)
                    
                    // Then
                    expect(mockFavoritesUseCase.addToFavoritesCalled).to(beTrue())
                    expect(mockFavoritesUseCase.addToFavoritesUsername).to(equal(username))
                }
                
                it("should remove from favorites") {
                    // Given
                    let username = "testuser"
                    
                    // When
                    viewModel.removeFromFavorites(username: username)
                    
                    // Then
                    expect(mockFavoritesUseCase.removeFromFavoritesCalled).to(beTrue())
                    expect(mockFavoritesUseCase.removeFromFavoritesUsername).to(equal(username))
                }
                
                it("should check if username is favorite") {
                    // Given
                    let username = "testuser"
                    mockFavoritesUseCase.mockIsFavorite = true
                    
                    // When
                    let result = viewModel.isFavorite(username: username)
                    
                    // Then
                    expect(mockFavoritesUseCase.isFavoriteCalled).to(beTrue())
                    expect(mockFavoritesUseCase.isFavoriteUsername).to(equal(username))
                    expect(result).to(beTrue())
                }
                
                it("should toggle favorite status") {
                    // Given
                    let username = "testuser"
                    
                    // When
                    viewModel.toggleFavorite(username: username)
                    
                    // Then
                    expect(mockFavoritesUseCase.toggleFavoriteCalled).to(beTrue())
                    expect(mockFavoritesUseCase.toggleFavoriteUsername).to(equal(username))
                }
            }
            
            context("when opening URLs") {
                it("should set URL for user in browser") {
                    // Given
                    let username = "testuser"
                    let expectedURL = URL(string: "https://github.com/testuser")!
                    mockOpenURLUseCase.mockProfileURL = expectedURL
                    
                    // When
                    viewModel.openInBrowser(username: username)
                    
                    // Then
                    expect(mockOpenURLUseCase.createGitHubProfileURLCalled).to(beTrue())
                    expect(mockOpenURLUseCase.createGitHubProfileURLUsername).to(equal(username))
                    expect(viewModel.urlToOpen).to(equal(expectedURL))
                }
                
                it("should set URL for repository in browser") {
                    // Given
                    let mockUser = User.createMock()
                    let mockRepo = Repository.createMock()
                    let mockRepoUI = RepositoryUIModel(from: mockRepo)
                    viewModel.state = .loaded(mockUser, [mockRepo])
                    
                    // When
                    viewModel.openRepositoryInBrowser(repository: mockRepoUI)
                    
                    // Then
                    expect(mockOpenURLUseCase.createRepositoryURLCalled).to(beTrue())
                    expect(mockOpenURLUseCase.createRepositoryURLRepository?.id).to(equal(mockRepo.id))
                    expect(viewModel.urlToOpen).to(equal(mockOpenURLUseCase.mockRepositoryURL))
                }
            }
        }
    }
}
#endif 