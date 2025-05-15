import SwiftUI

struct TechnologyBadgeView: View {
    let name: String
    let iconName: String
    
    private enum Constants {
        enum Layout {
            static let spacing: CGFloat = 4
            static let horizontalPadding: CGFloat = 8
            static let verticalPadding: CGFloat = 4
            static let cornerRadius: CGFloat = 4
        }
        
        enum Colors {
            static let background = Color.blue.opacity(0.1)
        }
    }
    
    var body: some View {
        HStack(spacing: Constants.Layout.spacing) {
            Image(systemName: iconName)
                .font(.caption2)
            Text(name)
                .font(.caption2)
        }
        .padding(.horizontal, Constants.Layout.horizontalPadding)
        .padding(.vertical, Constants.Layout.verticalPadding)
        .background(Constants.Colors.background)
        .cornerRadius(Constants.Layout.cornerRadius)
    }
}
