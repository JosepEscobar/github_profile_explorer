import SwiftUI

public struct SearchBarView: View {
    @Binding private var text: String
    private let placeholder: String
    private let onSubmit: () -> Void
    private let onCancel: () -> Void
    private let showKeyboardAutomatically: Bool
    
    @FocusState private var isInputFocused: Bool
    
    public init(
        text: Binding<String>,
        placeholder: String = "Search",
        onSubmit: @escaping () -> Void = {},
        onCancel: @escaping () -> Void = {},
        showKeyboardAutomatically: Bool = false
    ) {
        self._text = text
        self.placeholder = placeholder
        self.onSubmit = onSubmit
        self.onCancel = onCancel
        self.showKeyboardAutomatically = showKeyboardAutomatically
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField(placeholder, text: $text)
                    .disableAutocorrection(true)
                    .focused($isInputFocused)
                    .onSubmit(onSubmit)
                    .submitLabel(.search)
                
                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .transition(.opacity)
                    .animation(.default, value: text)
                }
            }
            .padding(8)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(10)
            
            if isInputFocused {
                Button("Cancel") {
                    isInputFocused = false
                    text = ""
                    onCancel()
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .animation(.default, value: isInputFocused)
            }
        }
        .padding(.horizontal)
        .onAppear {
            if showKeyboardAutomatically {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isInputFocused = true
                }
            }
        }
    }
}

#Preview {
    VStack {
        SearchBarView(text: .constant(""))
            .padding(.top)
        
        SearchBarView(text: .constant("apple"))
            .padding(.top)
        
        Spacer()
    }
} 