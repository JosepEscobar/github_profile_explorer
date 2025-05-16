#if os(iOS)
import SwiftUI

struct iPadOSStatView: View {
    private enum Constants {
        enum Layout {
            static let spacing: CGFloat = 4
            static let verticalPadding: CGFloat = 8
            static let cornerRadius: CGFloat = 8
        }
        
        enum Colors {
            static let accent = Color.blue
            static let background = Color.gray.opacity(0.1)
            static let secondary = Color.secondary
        }
        
        enum Typography {
            static let iconSize = Font.title3
            static let valueSize = Font.headline
            static let titleSize = Font.caption
        }
    }
    
    let count: String
    let title: String
    let icon: String
    
    var body: some View {
        VStack(spacing: Constants.Layout.spacing) {
            Image(systemName: icon)
                .font(Constants.Typography.iconSize)
                .foregroundColor(Constants.Colors.accent)
            
            Text(count)
                .font(Constants.Typography.valueSize)
            
            Text(title)
                .font(Constants.Typography.titleSize)
                .foregroundColor(Constants.Colors.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Constants.Layout.verticalPadding)
        .background(Constants.Colors.background)
        .cornerRadius(Constants.Layout.cornerRadius)
    }
}

#Preview {
    HStack {
        iPadOSStatView(count: "120", title: "Seguidores", icon: "person.2")
        iPadOSStatView(count: "50", title: "Siguiendo", icon: "person.badge.plus")
        iPadOSStatView(count: "35", title: "Repos", icon: "book.closed")
    }
    .padding()
}
#endif 