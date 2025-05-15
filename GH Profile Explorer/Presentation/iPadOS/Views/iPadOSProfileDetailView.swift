#if os(iOS)
import SwiftUI

struct iPadOSProfileDetailView: View {
    private enum Constants {
        enum Layout {
            static let mainSpacing: CGFloat = 24
            static let innerSpacing: CGFloat = 16
            static let bioSpacing: CGFloat = 8
            static let sectionSpacing: CGFloat = 8
            static let statSpacing: CGFloat = 16
            static let avatarSize: CGFloat = 160
            static let avatarCornerRadius: CGFloat = 80
            static let cornerRadius: CGFloat = 12
        }
        
        enum Colors {
            static let background = Color.primary.opacity(0.05)
            static let shadowColor = Color.black.opacity(0.1)
            static let secondary = Color.secondary
        }
        
        enum Strings {
            static let expand = "expand".localized
            static let collapse = "collapse".localized
            static let viewInGitHub = "view_on_github".localized
            static let biography = "biography".localized
            static let location = "location".localized
            static let statistics = "statistics".localized
            static let followers = "followers".localized
            static let following = "following".localized
            static let repos = "repos".localized
            static let gists = "gists".localized
            static let shareProfile = "share_profile".localized
        }
        
        enum Images {
            static let chevronLeft = "chevron.left"
            static let chevronRight = "chevron.right"
            static let safari = "safari"
            static let location = "location"
            static let followers = "person.2"
            static let following = "person.badge.plus"
            static let repos = "book.closed"
            static let gists = "text.alignleft"
            static let qrcode = "qrcode"
        }
        
        enum Typography {
            static let expandFont = Font.caption
            static let nameFont = Font.title
            static let nameWeight = Font.Weight.bold
            static let usernameFont = Font.headline
            static let sectionTitleFont = Font.headline
            static let bodyFont = Font.body
        }
    }
    
    let user: UserUIModel
    var isDetailExpanded: Bool
    var onToggleExpand: () -> Void
    var onOpenInSafari: (String) -> Void
    var onShowQRCode: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Layout.mainSpacing) {
            Button {
                onToggleExpand()
            } label: {
                HStack {
                    Image(systemName: isDetailExpanded ? Constants.Images.chevronLeft : Constants.Images.chevronRight)
                    Text(isDetailExpanded ? Constants.Strings.collapse : Constants.Strings.expand)
                }
                .font(Constants.Typography.expandFont)
                .foregroundColor(Constants.Colors.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            
            VStack(alignment: .center, spacing: Constants.Layout.innerSpacing) {
                AvatarImageView(url: user.avatarURL, size: Constants.Layout.avatarSize, cornerRadius: Constants.Layout.avatarCornerRadius)
                    .shadow(color: Constants.Colors.shadowColor, radius: 10)
                
                VStack(spacing: Constants.Layout.sectionSpacing) {
                    Text(user.name)
                        .font(Constants.Typography.nameFont)
                        .fontWeight(Constants.Typography.nameWeight)
                        .lineLimit(1)
                    
                    Text("@\(user.login)")
                        .font(Constants.Typography.usernameFont)
                        .foregroundColor(Constants.Colors.secondary)
                }
                
                Button {
                    onOpenInSafari(user.login)
                } label: {
                    Label(Constants.Strings.viewInGitHub, systemImage: Constants.Images.safari)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                #if !os(tvOS)
                .controlSize(.large)
                #endif
            }
            .frame(maxWidth: .infinity)
            
            if let bio = user.bio, !bio.isEmpty {
                VStack(alignment: .leading, spacing: Constants.Layout.bioSpacing) {
                    Text(Constants.Strings.biography)
                        .font(Constants.Typography.sectionTitleFont)
                    
                    Text(bio)
                        .font(Constants.Typography.bodyFont)
                        .foregroundColor(Constants.Colors.secondary)
                }
            }
            
            if let location = user.location {
                VStack(alignment: .leading, spacing: Constants.Layout.bioSpacing) {
                    Text(Constants.Strings.location)
                        .font(Constants.Typography.sectionTitleFont)
                    
                    Label(location, systemImage: Constants.Images.location)
                        .font(Constants.Typography.bodyFont)
                        .foregroundColor(Constants.Colors.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: Constants.Layout.bioSpacing) {
                Text(Constants.Strings.statistics)
                    .font(Constants.Typography.sectionTitleFont)
                
                HStack(spacing: Constants.Layout.statSpacing) {
                    iPadOSStatView(count: user.followers, title: Constants.Strings.followers, icon: Constants.Images.followers)
                    iPadOSStatView(count: user.following, title: Constants.Strings.following, icon: Constants.Images.following)
                    iPadOSStatView(count: user.publicRepos, title: Constants.Strings.repos, icon: Constants.Images.repos)
                    if user.publicGists != "0" {
                        iPadOSStatView(count: user.publicGists, title: Constants.Strings.gists, icon: Constants.Images.gists)
                    }
                }
            }
            
            Button {
                onShowQRCode()
            } label: {
                Label(Constants.Strings.shareProfile, systemImage: Constants.Images.qrcode)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .padding()
        .background(Constants.Colors.background)
        .cornerRadius(Constants.Layout.cornerRadius)
        .shadow(color: Constants.Colors.shadowColor, radius: 5)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    iPadOSProfileDetailView(
        user: UserUIModel.mock(), 
        isDetailExpanded: true, 
        onToggleExpand: {}, 
        onOpenInSafari: { _ in }, 
        onShowQRCode: {}
    )
    .frame(width: 500)
    .padding()
}
#endif 