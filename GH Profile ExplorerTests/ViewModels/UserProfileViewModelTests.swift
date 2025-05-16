import Quick
import Nimble
import Foundation
@testable import GH_Profile_Explorer

class UserProfileViewModelTests: QuickSpec {
    override class func spec() {
        var viewModel: UserProfileViewModel!
        var mockFetchUserUseCase: MockFetchUserUseCase!
        var mockFetchRepositoriesUseCase: MockFetchRepositoriesUseCase!
        
        beforeEach {
            mockFetchUserUseCase = MockFetchUserUseCase()
            mockFetchRepositoriesUseCase = MockFetchRepositoriesUseCase()
            viewModel = UserProfileViewModel(
                fetchUserUseCase: mockFetchUserUseCase,
                fetchRepositoriesUseCase: mockFetchRepositoriesUseCase
            )
        }
        
        describe("UserProfileViewModel") {
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
                    
                    // Then - should be loaded with the mock data
                    expect(viewModel.state).toEventually(equal(.loaded(mockUser, mockRepositories)), timeout: .seconds(3))
                    expect(mockFetchUserUseCase.executeCalled).to(beTrue())
                    expect(mockFetchUserUseCase.executeUsername).to(equal("testuser"))
                }
                
                it("should update state to error when username is empty") {
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
                    
                    // No debería llamar al caso de uso
                    expect(mockFetchUserUseCase.executeCalled).to(beFalse())
                }
                
                it("should update state to error when fetchUserUseCase fails") {
                    // Given
                    mockFetchUserUseCase.mockResult = .failure(AppError.userNotFound)
                    viewModel.username = "testuser"
                    
                    // When
                    viewModel.fetchUserProfile()
                    
                    // Then - should be error
                    expect {
                        if case .error = viewModel.state {
                            return true
                        }
                        return false
                    }.toEventually(beTrue(), timeout: .seconds(3))
                    
                    expect {
                        if case .error(let error) = viewModel.state, error == AppError.userNotFound {
                            return true
                        }
                        return false
                    }.toEventually(beTrue(), timeout: .seconds(3))
                    
                    expect(mockFetchUserUseCase.executeCalled).to(beTrue())
                    expect(mockFetchUserUseCase.executeUsername).to(equal("testuser"))
                }
                
                it("should update state to error when fetchRepositoriesUseCase fails") {
                    // Given
                    let mockUser = User.createMock()
                    mockFetchUserUseCase.mockResult = .success(mockUser)
                    mockFetchRepositoriesUseCase.mockResult = .failure(AppError.networkError)
                    viewModel.username = "testuser"
                    
                    // When
                    viewModel.fetchUserProfile()
                    
                    // Then - should be error
                    expect {
                        if case .error = viewModel.state {
                            return true
                        }
                        return false
                    }.toEventually(beTrue(), timeout: .seconds(3))
                    
                    expect {
                        if case .error(let error) = viewModel.state, error == AppError.networkError {
                            return true
                        }
                        return false
                    }.toEventually(beTrue(), timeout: .seconds(3))
                    
                    expect(mockFetchUserUseCase.executeCalled).to(beTrue())
                    expect(mockFetchUserUseCase.executeUsername).to(equal("testuser"))
                    expect(mockFetchRepositoriesUseCase.executeCalled).to(beTrue())
                    expect(mockFetchRepositoriesUseCase.executeUsername).to(equal("testuser"))
                }
            }
        }
    }
}
