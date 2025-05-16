#if os(iOS)
import SwiftUI

struct UserProfileHeaderView: View {
    let user: UserUIModel
    
    private enum Constants {
        enum Images {
            static let location = "location"
            static let followers = "person.2"
            static let repositories = "book.closed"
        }
        
        enum Layout {
            static let spacing: CGFloat = 16
            static let avatarSize: CGFloat = 100
            static let avatarCornerRadius: CGFloat = 50
            static let itemSpacing: CGFloat = 4
            static let statsSpacing: CGFloat = 12
            static let statsTopPadding: CGFloat = 4
            static let cornerRadius: CGFloat = 12
            static let shadowRadius: CGFloat = 5
        }
        
        enum Colors {
            static let background = Color.primary.opacity(0.05)
            static let shadow = Color.black.opacity(0.05)
        }
    }
    
    var body: some View {
        HStack(spacing: Constants.Layout.spacing) {
            AvatarImageView(url: user.avatarURL, size: Constants.Layout.avatarSize, cornerRadius: Constants.Layout.avatarCornerRadius)
            
            VStack(alignment: .leading, spacing: Constants.Layout.itemSpacing) {
                Text(user.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("@\(user.login)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let location = user.location {
                    Label(location, systemImage: Constants.Images.location)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: Constants.Layout.statsSpacing) {
                    Label(user.followers, systemImage: Constants.Images.followers)
                        .font(.caption)
                    
                    Label(user.publicRepos, systemImage: Constants.Images.repositories)
                        .font(.caption)
                }
                .padding(.top, Constants.Layout.statsTopPadding)
            }
            
            Spacer()
        }
        .padding()
        .background(Constants.Colors.background)
        .cornerRadius(Constants.Layout.cornerRadius)
        .shadow(color: Constants.Colors.shadow, radius: Constants.Layout.shadowRadius)
    }
}

#Preview {
    UserProfileHeaderView(user: UserUIModel.mock())
        .padding()
}
#endif 