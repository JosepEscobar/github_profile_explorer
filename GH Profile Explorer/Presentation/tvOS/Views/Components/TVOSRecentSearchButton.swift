#if os(tvOS)
import SwiftUI

struct TVOSRecentSearchButton: View {
    private enum Constants {
        enum Layout {
            static let spacing: CGFloat = 12
            static let paddingHorizontal: CGFloat = 25
            static let paddingVertical: CGFloat = 20
            static let height: CGFloat = 70
            static let cornerRadius: CGFloat = 12
            static let borderWidth: CGFloat = 4
            static let focusScaleEffect: CGFloat = 1.05
        }
        
        enum Colors {
            static let icon = Color.white
            static let text = Color.white
            static let background = Color.black.opacity(0.5)
            static let border = Color.white
        }
        
        enum Images {
            static let clock = "clock"
        }
    }
    
    let username: String
    let action: () -> Void
    @FocusState private var focused: Bool
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Constants.Layout.spacing) {
                Image(systemName: Constants.Images.clock)
                    .foregroundColor(Constants.Colors.icon)
                
                Text(username)
                    .font(.headline)
                    .foregroundColor(Constants.Colors.text)
            }
            .padding(.horizontal, Constants.Layout.paddingHorizontal)
            .padding(.vertical, Constants.Layout.paddingVertical)
            .frame(height: Constants.Layout.height)
            .background(
                RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                    .fill(Constants.Colors.background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                    .stroke(Constants.Colors.border, lineWidth: focused ? Constants.Layout.borderWidth : 0)
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
        TVOSRecentSearchButton(username: "ejemplo") {}
    }
    .padding()
    .background(Color.gray.opacity(0.3))
}
#endif

