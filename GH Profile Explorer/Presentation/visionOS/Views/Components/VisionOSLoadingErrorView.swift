#if os(visionOS)
import SwiftUI

struct VisionOSLoadingView: View {
    private enum Constants {
        enum Layout {
            static let spacing: CGFloat = 16
        }
        
        enum Colors {
            static let text = Color.secondary
        }
    }
    
    let message: String
    
    var body: some View {
        VStack(spacing: Constants.Layout.spacing) {
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(1.5)
            
            Text(message)
                .font(.headline)
                .foregroundColor(Constants.Colors.text)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct VisionOSErrorView: View {
    private enum Constants {
        enum Layout {
            static let spacing: CGFloat = 20
            static let iconSize: CGFloat = 60
            static let buttonPadding: CGFloat = 16
            static let cornerRadius: CGFloat = 10
        }
        
        enum Colors {
            static let icon = Color.red
            static let title = Color.primary
            static let message = Color.secondary
            static let buttonBackground = Color.blue
            static let buttonText = Color.white
        }
        
        enum Images {
            static let error = "exclamationmark.triangle.fill"
        }
        
        enum Strings {
            static let retry = "retry"
            static let error = "error"
        }
    }
    
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: Constants.Layout.spacing) {
            Image(systemName: Constants.Images.error)
                .font(.system(size: Constants.Layout.iconSize))
                .foregroundColor(Constants.Colors.icon)
                .symbolEffect(.pulse)
            
            Text(Constants.Strings.error.localized)
                .font(.title2.bold())
                .foregroundColor(Constants.Colors.title)
            
            Text(error.localizedDescription)
                .font(.headline)
                .foregroundColor(Constants.Colors.message)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: retryAction) {
                Text(Constants.Strings.retry.localized)
                    .padding(Constants.Layout.buttonPadding)
                    .background(Constants.Colors.buttonBackground)
                    .foregroundColor(Constants.Colors.buttonText)
                    .cornerRadius(Constants.Layout.cornerRadius)
            }
            .buttonStyle(.plain)
            .hoverEffect(.lift)
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// Extensión para obtener cadenas localizadas
private extension String {
    enum LoadingErrorStrings {
        static let retry = "retry"
        static let error = "error"
    }
    
    static var retry: String { LoadingErrorStrings.retry }
    static var error: String { LoadingErrorStrings.error }
    
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}

#Preview {
    Group {
        VisionOSLoadingView(message: "Cargando perfil...")
            .previewDisplayName("Loading")
        
        VisionOSErrorView(
            error: NSError(domain: "com.app.error", code: 404, userInfo: [NSLocalizedDescriptionKey: "No se pudo cargar el perfil. Por favor, intente de nuevo."]),
            retryAction: {}
        )
        .previewDisplayName("Error")
    }
}
#endif 