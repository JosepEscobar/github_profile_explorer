#if os(visionOS)
import SwiftUI

struct VisionOSProfileHeaderView: View {
    private enum Constants {
        enum Layout {
            static let spacing: CGFloat = 16
            static let avatarSize: CGFloat = 100
            static let avatarCornerRadius: CGFloat = 50
            static let borderWidth: CGFloat = 2
            static let shadowRadius: CGFloat = 10
            static let statsSpacing: CGFloat = 24
            static let bioMaxWidth: CGFloat = 600
            static let containerPadding: CGFloat = 30
            static let locationSpacing: CGFloat = 6
            static let cornerRadius: CGFloat = 20
            static let glassBlur: CGFloat = 0.15
        }
        
        enum Colors {
            static let avatarBorder = Color.blue.opacity(0.5)
            static let shadow = Color.blue.opacity(0.3)
            static let statsIcon = Color.blue
            static let locationIcon = Color.blue
            static let divider = Color.gray.opacity(0.3)
            static let containerBackground = Color.black.opacity(0.1)
        }
        
        enum Images {
            static let followers = "person.2.fill"
            static let following = "person.badge.plus"
            static let repositories = "book.closed.fill"
            static let gists = "text.alignleft"
            static let location = "location.fill"
            static let github = "link"
        }
        
        enum Strings {
            static let followers = "followers"
            static let following = "following"
            static let repositories = "repositories"
            static let gists = "gists"
            static let viewOnGitHub = "view_on_github"
        }
    }
    
    let user: UserUIModel
    let onOpenGitHubProfile: () -> Void
    
    var body: some View {
        VStack(spacing: Constants.Layout.spacing) {
            // Avatar and name
            HStack(spacing: Constants.Layout.spacing) {
                VisionOSAvatarView(
                    url: user.avatarURL,
                    size: Constants.Layout.avatarSize
                )
                .overlay(
                    Circle()
                        .stroke(Constants.Colors.avatarBorder, lineWidth: Constants.Layout.borderWidth)
                )
                .shadow(color: Constants.Colors.shadow, radius: Constants.Layout.shadowRadius)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name)
                        .font(.largeTitle.bold())
                        .foregroundColor(.primary)
                    
                    Text("@\(user.login)")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    // Location (if available)
                    if let location = user.location {
                        HStack(spacing: Constants.Layout.locationSpacing) {
                            Image(systemName: Constants.Images.location)
                                .foregroundColor(Constants.Colors.locationIcon)
                            
                            Text(location)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 4)
                    }
                    
                    // GitHub link button
                    Button(action: onOpenGitHubProfile) {
                        Label(Constants.Strings.viewOnGitHub.localized, systemImage: Constants.Images.github)
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                    .padding(.top, 8)
                }
                
                Spacer()
            }
            
            Divider()
                .background(Constants.Colors.divider)
            
            // Stats
            HStack(spacing: Constants.Layout.statsSpacing) {
                StatView(
                    value: user.followers,
                    label: Constants.Strings.followers.localized,
                    icon: Constants.Images.followers
                )
                
                StatView(
                    value: user.following,
                    label: Constants.Strings.following.localized,
                    icon: Constants.Images.following
                )
                
                StatView(
                    value: user.publicRepos,
                    label: Constants.Strings.repositories.localized,
                    icon: Constants.Images.repositories
                )
                
                StatView(
                    value: user.publicGists,
                    label: Constants.Strings.gists.localized,
                    icon: Constants.Images.gists
                )
            }
            
            // Bio (if available)
            if let bio = user.bio, !bio.isEmpty {
                Divider()
                    .background(Constants.Colors.divider)
                
                Text(bio)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: Constants.Layout.bioMaxWidth, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(Constants.Layout.containerPadding)
        .background(
            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                .fill(.ultraThinMaterial.opacity(Constants.Layout.glassBlur))
                .background(Constants.Colors.containerBackground)
        )
        .cornerRadius(Constants.Layout.cornerRadius)
    }
}

// Helper stat view
private struct StatView: View {
    private enum Constants {
        enum Layout {
            static let spacing: CGFloat = 8
            static let iconSize: CGFloat = 20
        }
        
        enum Colors {
            static let icon = Color.blue
            static let value = Color.primary
            static let label = Color.secondary
        }
    }
    
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: Constants.Layout.spacing) {
            Image(systemName: icon)
                .font(.system(size: Constants.Layout.iconSize))
                .foregroundColor(Constants.Colors.icon)
            
            Text(value)
                .font(.title3.bold())
                .foregroundColor(Constants.Colors.value)
            
            Text(label)
                .font(.caption)
                .foregroundColor(Constants.Colors.label)
        }
    }
}

#Preview {
    VisionOSProfileHeaderView(
        user: UserUIModel.mock(),
        onOpenGitHubProfile: {}
    )
    .padding()
}
#endif 