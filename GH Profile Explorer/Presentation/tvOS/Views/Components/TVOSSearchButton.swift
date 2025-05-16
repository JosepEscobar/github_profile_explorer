#if os(tvOS)
import SwiftUI

struct TVOSSearchButton: View {
    private enum Constants {
        enum Strings {
            static let search = "search"
        }
        
        enum Layout {
            static let spacing: CGFloat = 12
            static let paddingHorizontal: CGFloat = 30
            static let paddingVertical: CGFloat = 20
            static let cornerRadius: CGFloat = 10
            static let borderWidth: CGFloat = 4
            static let focusScaleEffect: CGFloat = 1.05
            static let iconSize: CGFloat = 30
            static let height: CGFloat = 80
        }
        
        enum Colors {
            static let background = Color.blue
            static let focusedBackground = Color.blue.opacity(0.8)
            static let borderFocused = Color.white
            static let text = Color.white
        }
        
        enum Images {
            static let search = "magnifyingglass"
        }
    }
    
    let action: () -> Void
    @FocusState private var focused: Bool
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Constants.Layout.spacing) {
                Image(systemName: Constants.Images.search)
                    .font(.system(size: Constants.Layout.iconSize))
                    .foregroundColor(Constants.Colors.text)
                
                Text(Constants.Strings.search.localized)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.text)
            }
            .frame(height: Constants.Layout.height)
            .padding(.horizontal, Constants.Layout.paddingHorizontal)
            .padding(.vertical, Constants.Layout.paddingVertical)
            .background(
                RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                    .fill(focused ? Constants.Colors.focusedBackground : Constants.Colors.background)
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
        TVOSSearchButton {}
    }
    .padding()
    .background(Color.gray.opacity(0.3))
}
#endif
