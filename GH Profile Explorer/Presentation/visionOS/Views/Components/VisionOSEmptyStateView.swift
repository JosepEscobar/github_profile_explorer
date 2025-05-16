#if os(visionOS)
import SwiftUI

struct VisionOSEmptyStateView: View {
    private enum Constants {
        enum Layout {
            static let spacing: CGFloat = 20
            static let iconSize: CGFloat = 60
            static let maxWidth: CGFloat = 400
            static let animationDuration: Double = 1.5
        }
        
        enum Colors {
            static let icon = Color.secondary
            static let title = Color.primary
            static let message = Color.secondary
        }
        
        enum Strings {
            static let defaultTitle = "no_results_found"
            static let defaultMessage = "try_different_search"
        }
    }
    
    let icon: String
    let title: String
    let message: String
    var action: (() -> Void)? = nil
    var actionLabel: String? = nil
    
    init(
        icon: String,
        title: String? = nil,
        message: String? = nil,
        action: (() -> Void)? = nil,
        actionLabel: String? = nil
    ) {
        self.icon = icon
        self.title = title ?? Constants.Strings.defaultTitle.localized
        self.message = message ?? Constants.Strings.defaultMessage.localized
        self.action = action
        self.actionLabel = actionLabel
    }
    
    var body: some View {
        VStack(spacing: Constants.Layout.spacing) {
            // Icon with animation
            Image(systemName: icon)
                .font(.system(size: Constants.Layout.iconSize))
                .foregroundColor(Constants.Colors.icon)
                .symbolEffect(.pulse, options: .repeating)
            
            // Title and message
            Text(title)
                .font(.title2.bold())
                .foregroundColor(Constants.Colors.title)
                .multilineTextAlignment(.center)
            
            Text(message)
                .font(.headline)
                .foregroundColor(Constants.Colors.message)
                .multilineTextAlignment(.center)
                .frame(maxWidth: Constants.Layout.maxWidth)
            
            // Optional action button
            if let action = action, let actionLabel = actionLabel {
                Button(action: action) {
                    Text(actionLabel)
                        .padding()
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .hoverEffect(.lift)
                .padding(.top, 10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    VisionOSEmptyStateView(
        icon: "magnifyingglass",
        title: "No se encontraron usuarios",
        message: "Intenta con una búsqueda diferente",
        action: {},
        actionLabel: "Buscar"
    )
}
#endif 