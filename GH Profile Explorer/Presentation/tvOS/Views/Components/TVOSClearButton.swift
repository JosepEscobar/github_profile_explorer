#if os(tvOS)
import SwiftUI

struct TVOSClearButton: View {
    private enum Constants {
        enum Strings {
            static let clear = "clear"
        }
        
        enum Layout {
            static let paddingHorizontal: CGFloat = 20
            static let paddingVertical: CGFloat = 10
            static let cornerRadius: CGFloat = 8
            static let borderWidth: CGFloat = 3
            static let focusScaleEffect: CGFloat = 1.05
        }
        
        enum Colors {
            static let background = Color.blue.opacity(0.7)
            static let borderFocused = Color.white
            static let text = Color.white
        }
    }
    
    let action: () -> Void
    @FocusState private var focused: Bool
    
    var body: some View {
        Button(action: action) {
            Text(Constants.Strings.clear.localized)
                .foregroundColor(Constants.Colors.text)
                .font(.headline)
                .padding(.horizontal, Constants.Layout.paddingHorizontal)
                .padding(.vertical, Constants.Layout.paddingVertical)
                .background(
                    RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                        .fill(Constants.Colors.background)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                        .stroke(Constants.Colors.borderFocused, lineWidth: focused ? Constants.Layout.borderWidth : 0)
                )
                .scaleEffect(focused ? Constants.Layout.focusScaleEffect : 1.0)
        }
        .buttonStyle(.card)
        .focused($focused)
    }
}

// MARK: - Vista de previsualización
#Preview {
    VStack(spacing: 20) {
        TVOSClearButton {}
    }
    .padding()
    .background(Color.gray.opacity(0.3))
}
#endif
