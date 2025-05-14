import Foundation

public enum ViewState: Equatable {
    case idle
    case loading
    case loaded(User, [Repository])
    case error(AppError)
    
    public static func == (lhs: ViewState, rhs: ViewState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading):
            return true
        case let (.loaded(user1, repos1), .loaded(user2, repos2)):
            return user1 == user2 && repos1 == repos2
        case let (.error(error1), .error(error2)):
            return error1 == error2
        default:
            return false
        }
    }
} 