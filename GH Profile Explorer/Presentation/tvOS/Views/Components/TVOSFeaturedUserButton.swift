#if os(tvOS)
import SwiftUI

struct TVOSFeaturedUserButton: View {
    private enum Constants {
        enum Layout {
            static let spacing: CGFloat = 15
            static let avatarSize: CGFloat = 140
            static let avatarCornerRadius: CGFloat = 70
            static let width: CGFloat = 180
            static let height: CGFloat = 220
            static let borderWidth: CGFloat = 4
            static let focusScaleEffect: CGFloat = 1.1
            static let shadowRadius: CGFloat = 15
            static let defaultShadowRadius: CGFloat = 5
        }
        
        enum Colors {
            static let shadow = Color.blue.opacity(0.5)
            static let border = Color.white
            static let fallbackIcon = Color.gray
            static let username = Color.white
        }
        
        enum Images {
            static let fallbackAvatar = "person.circle.fill"
        }
        
        enum URLs {
            static let githubAvatarBase = "https://github.com/"
            static let avatarSuffix = ".png"
        }
    }
    
    let username: String
    let action: () -> Void
    @FocusState private var focused: Bool
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Constants.Layout.spacing) {
                ZStack {
                    if let url = URL(string: Constants.URLs.githubAvatarBase + username + Constants.URLs.avatarSuffix) {
                        AvatarImageView(
                            url: url,
                            size: Constants.Layout.avatarSize,
                            cornerRadius: Constants.Layout.avatarCornerRadius
                        )
                        .shadow(
                            color: Constants.Colors.shadow,
                            radius: focused ? Constants.Layout.shadowRadius : Constants.Layout.defaultShadowRadius
                        )
                    } else {
                        Image(systemName: Constants.Images.fallbackAvatar)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Constants.Layout.avatarSize, height: Constants.Layout.avatarSize)
                            .clipShape(Circle())
                            .foregroundColor(Constants.Colors.fallbackIcon)
                    }
                }
                .overlay(
                    Circle()
                        .stroke(Constants.Colors.border, lineWidth: focused ? Constants.Layout.borderWidth : 0)
                )
                
                Text(username)
                    .font(.title2)
                    .foregroundColor(Constants.Colors.username)
            }
            .frame(width: Constants.Layout.width, height: Constants.Layout.height)
            .scaleEffect(focused ? Constants.Layout.focusScaleEffect : 1.0)
            .animation(.spring(), value: focused)
        }
        .buttonStyle(.card)
        .focused($focused)
    }
}

// MARK: - Vista de previsualización
#Preview {
    VStack(spacing: 20) {
        TVOSFeaturedUserButton(username: "apple") {}
    }
    .padding()
    .background(Color.gray.opacity(0.3))
}
#endif
