#if os(tvOS)
import SwiftUI

struct TVFocusableButtonStyle: ButtonStyle {
    private enum Constants {
        enum Layout {
            static let cornerRadius: CGFloat = 16
            static let borderWidth: CGFloat = 4
            static let shadowRadius: CGFloat = 10
            static let animationDuration: Double = 0.2
            static let pressedScale: CGFloat = 0.95
        }
        
        enum Effects {
            static let pressBrightness: Double = 0.3
        }
    }
    
    var color: Color = .white
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .brightness(configuration.isPressed ? Constants.Effects.pressBrightness : 0)
            .scaleEffect(configuration.isPressed ? Constants.Layout.pressedScale : 1.0)
            .shadow(color: configuration.isPressed ? color : Color.clear, radius: Constants.Layout.shadowRadius)
            .animation(.easeInOut(duration: Constants.Layout.animationDuration), value: configuration.isPressed)
            .contentShape(Rectangle())
            .overlay(
                RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                    .stroke(color, lineWidth: Constants.Layout.borderWidth)
                    .opacity(0)
                    .animation(.easeInOut(duration: Constants.Layout.animationDuration), value: configuration.isPressed)
            )
    }
}

// MARK: - Vista de previsualización
#Preview {
    HStack {
        Button("Normal") {}
            .buttonStyle(TVFocusableButtonStyle())
            .padding()
        
        Button("Custom Color") {}
            .buttonStyle(TVFocusableButtonStyle(color: .blue))
            .padding()
    }
    .padding()
    .background(Color.black)
}
#endif 
