#if os(tvOS)
import SwiftUI

struct TVOSCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .brightness(configuration.isPressed ? 0.3 : 0)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == TVOSCardButtonStyle {
    static var tvCard: TVOSCardButtonStyle { TVOSCardButtonStyle() }
}

// MARK: - Vista de previsualización
#Preview {
    HStack(spacing: 20) {
        Button("Normal Button") {}
            .buttonStyle(.tvCard)
            .padding()
            .background(Color.blue.opacity(0.3))
            .cornerRadius(8)
        
        Button {} label: {
            Text("Custom Label")
                .padding()
                .background(Color.purple.opacity(0.3))
                .cornerRadius(8)
        }
        .buttonStyle(.tvCard)
    }
    .padding()
    .background(Color.black)
}
#endif 