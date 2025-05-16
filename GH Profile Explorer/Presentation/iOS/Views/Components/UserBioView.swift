#if os(iOS)
import SwiftUI

struct UserBioView: View {
    let bio: String?
    
    private enum Constants {
        enum Layout {
            static let cornerRadius: CGFloat = 12
            static let shadowRadius: CGFloat = 5
        }
        
        enum Colors {
            static let background = Color.primary.opacity(0.05)
            static let shadow = Color.black.opacity(0.05)
        }
    }
    
    var body: some View {
        if let bio = bio, !bio.isEmpty {
            Text(bio)
                .font(.body)
                .padding()
                .background(Constants.Colors.background)
                .cornerRadius(Constants.Layout.cornerRadius)
                .shadow(color: Constants.Colors.shadow, radius: Constants.Layout.shadowRadius)
        }
    }
}

#Preview {
    UserBioView(bio: "I'm a software engineer specialized in iOS and artificial intelligence systems, with a career built on curiosity, continuous improvement")
        .padding()
}
#endif 