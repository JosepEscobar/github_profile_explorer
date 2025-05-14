import SwiftUI

public struct ErrorView: View {
    private let error: AppError
    private let retryAction: () -> Void
    
    public init(error: AppError, retryAction: @escaping () -> Void = {}) {
        self.error = error
        self.retryAction = retryAction
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: errorIcon)
                .font(.system(size: 48))
                .foregroundColor(.red)
                .symbolEffect(.pulse)
            
            Text(errorTitle)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            if showRetryButton {
                Button {
                    retryAction()
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Try Again")
                    }
                    .frame(maxWidth: 200)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                #if !os(tvOS)
                .controlSize(.large)
                #endif
                .padding(.top, 8)
            }
        }
        .padding()
        .frame(maxWidth: 320)
    }
    
    private var errorIcon: String {
        switch error {
        case .networkError:
            return "wifi.slash"
        case .userNotFound:
            return "person.slash"
        case .serverError:
            return "server.rack"
        case .decodingError:
            return "doc.questionmark"
        case .unexpectedError:
            return "exclamationmark.triangle"
        }
    }
    
    private var errorTitle: String {
        switch error {
        case .networkError:
            return "Network Error"
        case .userNotFound:
            return "User Not Found"
        case .serverError:
            return "Server Error"
        case .decodingError:
            return "Data Error"
        case .unexpectedError:
            return "Unexpected Error"
        }
    }
    
    private var showRetryButton: Bool {
        switch error {
        case .userNotFound:
            return false
        default:
            return true
        }
    }
}

#Preview("Network Error") {
    ErrorView(error: .networkError)
}

#Preview("User Not Found") {
    ErrorView(error: .userNotFound)
}

#Preview("Server Error") {
    ErrorView(error: .serverError(code: 500))
} 