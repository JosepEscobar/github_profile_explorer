#if os(macOS)
import SwiftUI

struct MacOSUserDetailView: View {
    private enum Constants {
        enum Layout {
            static let avatarSize: CGFloat = 120
            static let avatarCornerRadius: CGFloat = 60
            static let spacing: CGFloat = 20
            static let statMinWidth: CGFloat = 80
        }
        
        enum Strings {
            static let followers = "followers".localized
            static let following = "following".localized
            static let repositories = "repositories".localized
            static let gists = "gists".localized
            static let biography = "biography".localized
            static let viewProfileOnGithub = "view_profile_on_github".localized
        }
        
        enum Images {
            static let followers = "person.2"
            static let following = "person.badge.plus"
            static let repositories = "book.closed"
            static let gists = "text.alignleft"
            static let location = "location"
            static let viewProfile = "arrow.up.right.square"
        }
    }
    
    let user: UserUIModel
    var onOpenInSafari: (String) -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Constants.Layout.spacing) {
                HStack(spacing: Constants.Layout.spacing) {
                    AvatarImageView(
                        url: user.avatarURL, 
                        size: Constants.Layout.avatarSize, 
                        cornerRadius: Constants.Layout.avatarCornerRadius
                    )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(user.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("@\(user.login)")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        if let location = user.location {
                            Label(location, systemImage: Constants.Images.location)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 16) {
                            MacOSStatView(
                                value: user.followers, 
                                title: Constants.Strings.followers, 
                                iconName: Constants.Images.followers
                            )
                            MacOSStatView(
                                value: user.following, 
                                title: Constants.Strings.following, 
                                iconName: Constants.Images.following
                            )
                            MacOSStatView(
                                value: user.publicRepos, 
                                title: Constants.Strings.repositories, 
                                iconName: Constants.Images.repositories
                            )
                            MacOSStatView(
                                value: user.publicGists, 
                                title: Constants.Strings.gists, 
                                iconName: Constants.Images.gists
                            )
                        }
                        .padding(.top, 8)
                    }
                    
                    Spacer()
                }
                
                if let bio = user.bio, !bio.isEmpty {
                    GroupBox(Constants.Strings.biography) {
                        Text(bio)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                    }
                }
                
                Button {
                    onOpenInSafari(user.login)
                } label: {
                    Label(Constants.Strings.viewProfileOnGithub, systemImage: Constants.Images.viewProfile)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct MacOSStatView: View {
    private enum Constants {
        enum Layout {
            static let minWidth: CGFloat = 80
            static let spacing: CGFloat = 4
        }
    }
    
    let value: String
    let title: String
    let iconName: String
    
    var body: some View {
        VStack(spacing: Constants.Layout.spacing) {
            Label(value, systemImage: iconName)
                .font(.headline)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(minWidth: Constants.Layout.minWidth)
    }
}

#Preview {
    MacOSUserDetailView(
        user: UserUIModel.mock(),
        onOpenInSafari: { _ in }
    )
}

#endif 