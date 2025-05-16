#if os(tvOS)
import SwiftUI

// MARK: - TVOSButtonCard

struct TVOSButtonCard: View {
    private enum Constants {
        enum Layout {
            static let spacing: CGFloat = 10
            static let padding: CGFloat = 16
            static let width: CGFloat = 180
            static let height: CGFloat = 120
            static let cornerRadius: CGFloat = 12
            static let borderWidth: CGFloat = 4
            static let focusScaleEffect: CGFloat = 1.1
        }
        
        enum Colors {
            static let background = Color.black.opacity(0.6)
            static let borderFocused = Color.white
            static let icon = Color.white
            static let title = Color.white
        }
    }
    
    let icon: String
    let title: String
    let action: () -> Void
    @FocusState private var focused: Bool
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Constants.Layout.spacing) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(Constants.Colors.icon)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(Constants.Colors.title)
            }
            .padding(Constants.Layout.padding)
            .frame(width: Constants.Layout.width, height: Constants.Layout.height)
            .background(
                RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                    .fill(Constants.Colors.background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                    .stroke(Constants.Colors.borderFocused, lineWidth: focused ? Constants.Layout.borderWidth : 0)
            )
            .scaleEffect(focused ? Constants.Layout.focusScaleEffect : 1.0)
            .animation(.spring(), value: focused)
        }
        .buttonStyle(.card)
        .focused($focused)
    }
}

// MARK: - Vista de previsualización
#Preview {
    VStack(spacing: 20) {
        TVOSButtonCard(icon: "magnifyingglass", title: "Buscar") {}
    }
    .padding()
    .background(Color.gray.opacity(0.3))
}
#endif 
