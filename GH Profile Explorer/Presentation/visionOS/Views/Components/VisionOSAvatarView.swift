#if os(visionOS)
import SwiftUI
import Kingfisher

// Componente para avatar grande con efectos 3D
struct VisionOSUserProfileAvatarView: View {
    private enum Constants {
        enum Layout {
            static let backgroundExtraPadding: CGFloat = 20
            static let shadowRadius: CGFloat = 15
            static let animationDuration: Double = 8
            static let maxRotationAngle: Double = 5
            static let placeholderPadding: CGFloat = 0.25
        }
        
        enum Colors {
            static let background = Color.blue.opacity(0.05)
            static let shadow = Color.blue.opacity(0.3)
            static let placeholderBackground = Color.gray.opacity(0.2)
            static let placeholderIcon = Color.gray
            static let avatarBackground = Color.gray.opacity(0.1)
            static let avatarBorder = Color.secondary.opacity(0.2)
        }
        
        enum Images {
            static let placeholder = "person.fill"
        }
    }
    
    let url: URL
    let size: CGFloat
    @State private var rotationAngle = 0.0
    
    var body: some View {
        ZStack(alignment: .center) {
            // Fondo y efectos 3D
            Circle()
                .fill(Constants.Colors.background)
                .frame(width: size + Constants.Layout.backgroundExtraPadding, height: size + Constants.Layout.backgroundExtraPadding)
                .shadow(color: Constants.Colors.shadow, radius: Constants.Layout.shadowRadius)
                .rotation3DEffect(
                    .degrees(rotationAngle),
                    axis: (x: 0, y: 1, z: 0.2)
                )
                .onAppear {
                    withAnimation(.easeInOut(duration: Constants.Layout.animationDuration).repeatForever(autoreverses: true)) {
                        rotationAngle = Constants.Layout.maxRotationAngle
                    }
                }
            
            // Avatar estático superpuesto sobre los efectos 3D
            KFImage(url)
                .placeholder {
                    ZStack {
                        Circle().fill(Constants.Colors.placeholderBackground)
                        Image(systemName: Constants.Images.placeholder)
                            .resizable()
                            .scaledToFit()
                            .padding(size * Constants.Layout.placeholderPadding)
                            .foregroundColor(Constants.Colors.placeholderIcon)
                    }
                }
                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: size * 3, height: size * 3)))
                .cacheOriginalImage()
                .loadDiskFileSynchronously()
                .retry(maxCount: 3, interval: .seconds(2))
                .fade(duration: 0.3)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .background(Constants.Colors.avatarBackground)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Constants.Colors.avatarBorder, lineWidth: 1)
                )
        }
        .frame(width: size + Constants.Layout.backgroundExtraPadding, height: size + Constants.Layout.backgroundExtraPadding)
    }
}

// Componente para avatares pequeños (barra nav)
struct VisionOSAvatarImageView: View {
    private enum Constants {
        enum Layout {
            static let placeholderPadding: CGFloat = 0.25
            static let borderWidth: CGFloat = 1
            static let shadowRadius: CGFloat = 2
            static let shadowY: CGFloat = 1
        }
        
        enum Colors {
            static let placeholderBackground = Color.gray.opacity(0.2)
            static let placeholderIcon = Color.gray
            static let avatarBackground = Color.gray.opacity(0.1)
            static let avatarBorder = Color.gray.opacity(0.2)
            static let shadow = Color.black.opacity(0.1)
        }
        
        enum Images {
            static let placeholder = "person.fill"
        }
    }
    
    private let url: URL
    private let size: CGFloat
    private let cornerRadius: CGFloat
    
    init(url: URL, size: CGFloat = 80, cornerRadius: CGFloat = 40) {
        self.url = url
        self.size = size
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        KFImage(url)
            .placeholder {
                ZStack {
                    Color.gray.opacity(0.2)
                    Image(systemName: Constants.Images.placeholder)
                        .resizable()
                        .scaledToFit()
                        .padding(size * Constants.Layout.placeholderPadding)
                        .foregroundColor(Constants.Colors.placeholderIcon)
                }
            }
            .setProcessor(DownsamplingImageProcessor(size: CGSize(width: size * 2, height: size * 2)))
            .cacheOriginalImage()
            .retry(maxCount: 3, interval: .seconds(2))
            .fade(duration: 0.3)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .background(Constants.Colors.avatarBackground)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Constants.Colors.avatarBorder, lineWidth: Constants.Layout.borderWidth)
            )
            .shadow(color: Constants.Colors.shadow, radius: Constants.Layout.shadowRadius, x: 0, y: Constants.Layout.shadowY)
    }
}

#Preview {
    HStack(spacing: 40) {
        VisionOSUserProfileAvatarView(
            url: URL(string: "https://avatars.githubusercontent.com/u/12345678")!,
            size: 100
        )
        
        VisionOSAvatarImageView(
            url: URL(string: "https://avatars.githubusercontent.com/u/12345678")!,
            size: 60
        )
    }
    .padding()
    .background(.ultraThinMaterial)
}
#endif 