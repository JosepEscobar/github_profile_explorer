import Foundation

public enum AppError: Error, Equatable {
    case networkError
    case userNotFound
    case serverError(code: Int)
    case decodingError
    case unexpectedError(String)
    
    public var localizedDescription: String {
        switch self {
        case .networkError:
            return "A network error has occurred. Check your Internet connection and try again later."
        case .userNotFound:
            return "User not found. Please enter another name."
        case .serverError(let code):
            return "Server error: \(code). Please try again later."
        case .decodingError:
            return "There was an error processing the data. Please try again."
        case .unexpectedError(let message):
            return message
        }
    }
    
    public static func == (lhs: AppError, rhs: AppError) -> Bool {
        switch (lhs, rhs) {
        case (.networkError, .networkError),
             (.userNotFound, .userNotFound),
             (.decodingError, .decodingError):
            return true
        case (.serverError(let code1), .serverError(let code2)):
            return code1 == code2
        case (.unexpectedError(let message1), .unexpectedError(let message2)):
            return message1 == message2
        default:
            return false
        }
    }
} 