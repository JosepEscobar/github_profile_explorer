#if os(tvOS)
import SwiftUI
import Kingfisher

struct TVOSFeaturedUserButton: View {
    private enum Constants {
        enum Layout {
            static let spacing: CGFloat = 12
            static let width: CGFloat = 280
            static let height: CGFloat = 160
            static let cardCornerRadius: CGFloat = 10
            static let borderWidth: CGFloat = 2
            static let focusScaleEffect: CGFloat = 1.01
            static let shadowRadius: CGFloat = 10
            static let defaultShadowRadius: CGFloat = 5
            static let usernameTopPadding: CGFloat = 8
            static let usernameBottomPadding: CGFloat = 4
            static let textLeadingPadding: CGFloat = 3
        }
        
        enum Colors {
            static let shadow = Color.blue.opacity(0.5)
            static let border = Color.white
            static let fallbackIcon = Color.gray
            static let username = Color.white.opacity(0.9)
            static let subtitleText = Color.gray.opacity(0.8)
            static let usernameBackground = Color.black.opacity(0.0)
            static let cardOverlay = Color.black.opacity(0.2)
            static let gradient = LinearGradient(
                colors: [Color.black.opacity(0.0), Color.black.opacity(0.5)],
                startPoint: .top,
                endPoint: .bottom
            )
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
        VStack(alignment: .leading, spacing: Constants.Layout.spacing / 2) {
            // Tarjeta con imagen
            Button(action: action) {
                ZStack(alignment: .bottom) {
                    // Imagen de avatar
                    if let url = URL(string: Constants.URLs.githubAvatarBase + username + Constants.URLs.avatarSuffix) {
                        KFImage(url)
                            .placeholder {
                                ZStack {
                                    Color.gray.opacity(0.2)
                                    Image(systemName: Constants.Images.fallbackAvatar)
                                        .resizable()
                                        .scaledToFit()
                                        .padding(40)
                                        .foregroundColor(Constants.Colors.fallbackIcon)
                                }
                            }
                            .retry(maxCount: 3, interval: .seconds(2))
                            .fade(duration: 0.3)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: Constants.Layout.width, height: Constants.Layout.height)
                            .clipped()
                    } else {
                        ZStack {
                            Color.gray.opacity(0.2)
                            Image(systemName: Constants.Images.fallbackAvatar)
                                .resizable()
                                .scaledToFit()
                                .padding(40)
                                .foregroundColor(Constants.Colors.fallbackIcon)
                        }
                        .frame(width: Constants.Layout.width, height: Constants.Layout.height)
                    }
                    
                    // Degradado sutil en la parte inferior
                    Constants.Colors.gradient
                        .frame(height: Constants.Layout.height / 3)
                        .opacity(0.7)
                }
                .cornerRadius(Constants.Layout.cardCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.Layout.cardCornerRadius)
                        .stroke(focused ? Constants.Colors.border : Color.clear, lineWidth: Constants.Layout.borderWidth)
                )
                .shadow(color: Constants.Colors.shadow, radius: focused ? Constants.Layout.shadowRadius : Constants.Layout.defaultShadowRadius)
            }
            .buttonStyle(.card)
            .focused($focused)
            .scaleEffect(focused ? Constants.Layout.focusScaleEffect : 1.0)
            .animation(.spring(response: 0.3), value: focused)
            
            // Texto del nombre de usuario debajo de la tarjeta
            VStack(alignment: .leading, spacing: 3) {
                Text(username)
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundColor(Constants.Colors.username)
                    .lineLimit(1)
            }
            .padding(.top, Constants.Layout.usernameTopPadding)
            .padding(.bottom, Constants.Layout.usernameBottomPadding)
            .padding(.leading, Constants.Layout.textLeadingPadding)
        }
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
