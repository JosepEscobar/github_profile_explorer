#if os(iOS)
import SwiftUI

struct iPadOSProfileDetailView: View {
    let user: User
    var isDetailExpanded: Bool
    var onToggleExpand: () -> Void
    var onOpenInSafari: (String) -> Void
    var onShowQRCode: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Button {
                onToggleExpand()
            } label: {
                HStack {
                    Image(systemName: isDetailExpanded ? "chevron.left" : "chevron.right")
                    Text(isDetailExpanded ? "Comprimir" : "Expandir")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            
            VStack(alignment: .center, spacing: 16) {
                AvatarImageView(url: user.avatarURL, size: 160, cornerRadius: 80)
                    .shadow(color: .black.opacity(0.1), radius: 10)
                
                VStack(spacing: 8) {
                    Text(user.name ?? "")
                        .font(.title)
                        .fontWeight(.bold)
                        .lineLimit(1)
                    
                    Text("@\(user.login)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                Button {
                    onOpenInSafari(user.login)
                } label: {
                    Label("Ver en GitHub", systemImage: "safari")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                #if !os(tvOS)
                .controlSize(.large)
                #endif
            }
            .frame(maxWidth: .infinity)
            
            if let bio = user.bio, !bio.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Biografía")
                        .font(.headline)
                    
                    Text(bio)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            
            if let location = user.location {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ubicación")
                        .font(.headline)
                    
                    Label(location, systemImage: "location")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Estadísticas")
                    .font(.headline)
                
                HStack(spacing: 16) {
                    iPadOSStatView(count: user.followers, title: "Seguidores", icon: "person.2")
                    iPadOSStatView(count: user.following, title: "Siguiendo", icon: "person.badge.plus")
                    iPadOSStatView(count: user.publicRepos, title: "Repos", icon: "book.closed")
                    if user.publicGists > 0 {
                        iPadOSStatView(count: user.publicGists, title: "Gists", icon: "text.alignleft")
                    }
                }
            }
            
            Button {
                onShowQRCode()
            } label: {
                Label("Compartir perfil", systemImage: "qrcode")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .padding()
        .background(Color.primary.opacity(0.05))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    iPadOSProfileDetailView(
        user: User.mock(), 
        isDetailExpanded: true, 
        onToggleExpand: {}, 
        onOpenInSafari: { _ in }, 
        onShowQRCode: {}
    )
    .frame(width: 500)
    .padding()
}
#endif 