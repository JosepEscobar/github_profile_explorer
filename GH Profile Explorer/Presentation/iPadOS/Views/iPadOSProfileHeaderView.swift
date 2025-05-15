#if os(iOS)
import SwiftUI

struct iPadOSProfileHeaderView: View {
    private enum Constants {
        enum Layout {
            static let avatarSize: CGFloat = 100
            static let avatarCornerRadius: CGFloat = 50
            static let outerSpacing: CGFloat = 16
            static let itemSpacing: CGFloat = 20
            static let statsSpacing: CGFloat = 16
            static let textSpacing: CGFloat = 4
            static let cornerRadius: CGFloat = 12
            static let bioCornerRadius: CGFloat = 8
            static let topPadding: CGFloat = 4
        }
        
        enum Colors {
            static let background = Color.primary.opacity(0.05)
            static let bioBg = Color.gray.opacity(0.1)
            static let secondary = Color.secondary
            static let shadow = Color.black.opacity(0.1)
        }
        
        enum Images {
            static let safari = "safari"
            static let location = "location"
            static let followers = "person.2"
            static let following = "person.badge.plus"
            static let repositories = "book.closed"
        }
        
        enum Typography {
            static let titleFont = Font.title
            static let titleWeight = Font.Weight.bold
            static let subheadlineFont = Font.subheadline
        }
        
        enum Strings {
            static let viewOnGitHub = "view_on_github".localized
        }
    }
    
    let user: UserUIModel
    var onOpenInSafari: (String) -> Void
    
    var body: some View {
        VStack(spacing: Constants.Layout.outerSpacing) {
            HStack(spacing: Constants.Layout.itemSpacing) {
                AvatarImageView(url: user.avatarURL, size: Constants.Layout.avatarSize, cornerRadius: Constants.Layout.avatarCornerRadius)
                
                VStack(alignment: .leading, spacing: Constants.Layout.textSpacing) {
                    Text(user.name)
                        .font(Constants.Typography.titleFont)
                        .fontWeight(Constants.Typography.titleWeight)
                        .lineLimit(1)
                    
                    Text("@\(user.login)")
                        .font(Constants.Typography.subheadlineFont)
                        .foregroundColor(Constants.Colors.secondary)
                    
                    if let location = user.location {
                        Label(location, systemImage: Constants.Images.location)
                            .font(Constants.Typography.subheadlineFont)
                            .foregroundColor(Constants.Colors.secondary)
                    }
                    
                    HStack(spacing: Constants.Layout.statsSpacing) {
                        Label(user.followers, systemImage: Constants.Images.followers)
                            .font(Constants.Typography.subheadlineFont)
                        
                        Label(user.following, systemImage: Constants.Images.following)
                            .font(Constants.Typography.subheadlineFont)
                        
                        Label(user.publicRepos, systemImage: Constants.Images.repositories)
                            .font(Constants.Typography.subheadlineFont)
                    }
                    .padding(.top, Constants.Layout.topPadding)
                }
                
                Spacer()
                
                Button {
                    onOpenInSafari(user.login)
                } label: {
                    Label(Constants.Strings.viewOnGitHub, systemImage: Constants.Images.safari)
                }
                .buttonStyle(.bordered)
            }
            
            if let bio = user.bio, !bio.isEmpty {
                Text(bio)
                    .font(.body)
                    .foregroundColor(Constants.Colors.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Constants.Colors.bioBg)
                    .cornerRadius(Constants.Layout.bioCornerRadius)
            }
        }
        .padding()
        .background(Constants.Colors.background)
        .cornerRadius(Constants.Layout.cornerRadius)
        .shadow(color: Constants.Colors.shadow, radius: 5)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    iPadOSProfileHeaderView(
        user: UserUIModel.mock(),
        onOpenInSafari: { _ in }
    )
    .padding()
}
#endif 