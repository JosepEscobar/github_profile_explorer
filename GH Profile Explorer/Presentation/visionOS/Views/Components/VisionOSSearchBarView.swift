#if os(visionOS)
import SwiftUI

struct VisionOSSearchBarView: View {
    private enum Constants {
        enum Layout {
            static let height: CGFloat = 48
            static let cornerRadius: CGFloat = 12
            static let horizontalPadding: CGFloat = 16
            static let iconSize: CGFloat = 20
            static let clearButtonSize: CGFloat = 14
            static let clearButtonPadding: CGFloat = 8
        }
        
        enum Colors {
            static let background = Color.black.opacity(0.1)
            static let focusedBackground = Color.black.opacity(0.15)
            static let icon = Color.secondary
            static let placeholder = Color.secondary.opacity(0.8)
            static let text = Color.primary
            static let clearButton = Color.secondary.opacity(0.7)
            static let clearButtonHover = Color.secondary
        }
        
        enum Images {
            static let search = "magnifyingglass"
            static let clear = "xmark.circle.fill"
        }
    }
    
    @Binding var text: String
    var placeholder: String
    var onSubmit: (() -> Void)? = nil
    @State private var isFocused: Bool = false
    @State private var isClearButtonHovered: Bool = false
    
    var body: some View {
        HStack {
            // Search icon
            Image(systemName: Constants.Images.search)
                .font(.system(size: Constants.Layout.iconSize))
                .foregroundColor(Constants.Colors.icon)
            
            // Text field
            TextField(placeholder, text: $text)
                .font(.body)
                .foregroundColor(Constants.Colors.text)
                .padding(.horizontal, Constants.Layout.horizontalPadding)
                .onSubmit {
                    onSubmit?()
                }
                .tint(.blue)
                .onFocusChange { focused in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isFocused = focused
                    }
                }
            
            // Clear button
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: Constants.Images.clear)
                        .font(.system(size: Constants.Layout.clearButtonSize))
                        .foregroundColor(isClearButtonHovered ? Constants.Colors.clearButtonHover : Constants.Colors.clearButton)
                        .padding(Constants.Layout.clearButtonPadding)
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    isClearButtonHovered = hovering
                }
            }
        }
        .frame(height: Constants.Layout.height)
        .padding(.horizontal, Constants.Layout.horizontalPadding)
        .background(
            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                .fill(isFocused ? Constants.Colors.focusedBackground : Constants.Colors.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                .stroke(isFocused ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        VisionOSSearchBarView(
            text: .constant(""),
            placeholder: "Buscar repositorios..."
        )
        
        VisionOSSearchBarView(
            text: .constant("swift"),
            placeholder: "Buscar repositorios..."
        )
    }
    .padding()
    .background(.ultraThinMaterial)
}
#endif 