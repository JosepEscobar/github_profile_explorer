#if os(iOS)
import SwiftUI

struct iPadOSProfileHeaderView: View {
    let user: User
    var onOpenInSafari: (String) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                AvatarImageView(url: user.avatarURL, size: 100, cornerRadius: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name ?? user.login)
                        .font(.title)
                        .fontWeight(.bold)
                        .lineLimit(1)
                    
                    Text("@\(user.login)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let location = user.location {
                        Label(location, systemImage: "location")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 16) {
                        Label("\(user.followers)", systemImage: "person.2")
                            .font(.subheadline)
                        
                        Label("\(user.following)", systemImage: "person.badge.plus")
                            .font(.subheadline)
                        
                        Label("\(user.publicRepos)", systemImage: "book.closed")
                            .font(.subheadline)
                    }
                    .padding(.top, 4)
                }
                
                Spacer()
                
                Button {
                    onOpenInSafari(user.login)
                } label: {
                    Label("Ver en GitHub", systemImage: "safari")
                }
                .buttonStyle(.bordered)
            }
            
            if let bio = user.bio, !bio.isEmpty {
                Text(bio)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.primary.opacity(0.05))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    iPadOSProfileHeaderView(
        user: User.mock(),
        onOpenInSafari: { _ in }
    )
    .padding()
}
#endif 