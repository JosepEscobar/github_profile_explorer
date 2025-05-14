import SwiftUI

public struct LoadingView: View {
    private let message: String
    private let isFullScreen: Bool
    
    public init(message: String = "Loading...", isFullScreen: Bool = false) {
        self.message = message
        self.isFullScreen = isFullScreen
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                #if !os(tvOS)
                .controlSize(.large)
                #endif
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: isFullScreen ? .infinity : nil)
        .padding()
        .background(isFullScreen ? Color.primary.opacity(0.05) : nil)
    }
}

#Preview("Standard") {
    LoadingView()
        .padding()
}

#Preview("Full Screen") {
    LoadingView(message: "Cargando perfil...", isFullScreen: true)
} 