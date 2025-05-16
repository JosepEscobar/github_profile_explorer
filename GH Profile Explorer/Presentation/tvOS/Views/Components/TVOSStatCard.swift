#if os(tvOS)
import SwiftUI

struct StatCard: View {
    private enum Constants {
        enum Layout {
            static let spacing: CGFloat = 16
            static let width: CGFloat = 200
            static let height: CGFloat = 180
            static let iconSize: CGFloat = 36
            static let valueSize: CGFloat = 36
            static let titleSize: CGFloat = 20
            static let cornerRadius: CGFloat = 16
            static let borderWidth: CGFloat = 2
            static let focusedScale: CGFloat = 1.05
            static let shadowRadius: CGFloat = 10
            static let contentPadding: CGFloat = 20
            static let animationDuration: Double = 0.2
        }
        
        enum Colors {
            static let icon = Color.blue
            static let value = Color.white
            static let title = Color.white.opacity(0.8)
            static let background = Color(red: 0.1, green: 0.15, blue: 0.25)
            static let border = Color.blue.opacity(0.3)
            static let focusedBorder = Color.white
            static let shadow = Color.blue.opacity(0.6)
        }
    }
    
    let value: String
    let title: String
    let icon: String
    let isFocused: Bool
    
    init(value: String, title: String, icon: String, isFocused: Bool = false) {
        self.value = value
        self.title = title
        self.icon = icon
        self.isFocused = isFocused
    }
    
    var body: some View {
        VStack(spacing: Constants.Layout.spacing) {
            Image(systemName: icon)
                .font(.system(size: Constants.Layout.iconSize))
                .foregroundColor(Constants.Colors.icon)
            
            Text(value)
                .font(.system(size: Constants.Layout.valueSize, weight: .bold))
                .foregroundColor(Constants.Colors.value)
            
            Text(title)
                .font(.system(size: Constants.Layout.titleSize))
                .foregroundColor(Constants.Colors.title)
        }
        .padding(Constants.Layout.contentPadding)
        .frame(width: Constants.Layout.width, height: Constants.Layout.height)
        .background(
            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                .fill(Constants.Colors.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                .stroke(isFocused ? Constants.Colors.focusedBorder : Constants.Colors.border, 
                        lineWidth: isFocused ? Constants.Layout.borderWidth * 2 : Constants.Layout.borderWidth)
        )
        .scaleEffect(isFocused ? Constants.Layout.focusedScale : 1.0)
        .shadow(color: isFocused ? Constants.Colors.shadow : .clear, 
                radius: Constants.Layout.shadowRadius)
        .animation(.easeInOut(duration: Constants.Layout.animationDuration), value: isFocused)
    }
}

// MARK: - Vista de previsualización
#Preview {
    HStack(spacing: 20) {
        StatCard(value: "120", title: "Seguidores", icon: "person.2.fill")
        StatCard(value: "45", title: "Siguiendo", icon: "person.badge.plus", isFocused: true)
    }
    .padding()
    .background(Color.black)
}
#endif 