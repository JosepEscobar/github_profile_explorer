#if os(visionOS)
import SwiftUI
import Kingfisher
import RealityKit

struct VisionOSAvatarView: View {
    enum AvatarStyle {
        case large3D
        case small
    }
    
    private let url: URL
    private let size: CGFloat
    private let style: AvatarStyle
    
    @State private var rotationAngle = 0.0
    
    // Constructor único con estilo para determinar qué variante usar
    init(url: URL, size: CGFloat, style: AvatarStyle = .small) {
        self.url = url
        self.size = size
        self.style = style
    }
    
    var body: some View {
        switch style {
        case .large3D:
            large3DAvatar
        case .small:
            smallAvatar
        }
    }
    
    private var large3DAvatar: some View {
        ZStack(alignment: .center) {
            Circle()
                .fill(Color.blue.opacity(0.05))
                .frame(width: size + 20, height: size + 20)
                .shadow(color: .blue.opacity(0.3), radius: 15)
                .rotation3DEffect(
                    .degrees(rotationAngle),
                    axis: (x: 0, y: 1, z: 0.2)
                )
                .onAppear {
                    withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                        rotationAngle = 5
                    }
                }
            
            KFImage(url)
                .placeholder {
                    defaultPlaceholder
                }
                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: size * 3, height: size * 3)))
                .cacheOriginalImage()
                .loadDiskFileSynchronously()
                .retry(maxCount: 3, interval: .seconds(2))
                .fade(duration: 0.3)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .background(Color.gray.opacity(0.1))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
        }
        .frame(width: size + 20, height: size + 20)
    }
    
    private var smallAvatar: some View {
        KFImage(url)
            .placeholder {
                defaultPlaceholder
            }
            .setProcessor(DownsamplingImageProcessor(size: CGSize(width: size * 2, height: size * 2)))
            .cacheOriginalImage()
            .retry(maxCount: 3, interval: .seconds(2))
            .fade(duration: 0.3)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .background(Color.gray.opacity(0.1))
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var defaultPlaceholder: some View {
        ZStack {
            Circle().fill(Color.gray.opacity(0.2))
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .padding(size * 0.25)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    HStack(spacing: 40) {
        VisionOSAvatarView(
            url: URL(string: "https://avatars.githubusercontent.com/u/12345678")!,
            size: 100,
            style: .large3D
        )
        
        VisionOSAvatarView(
            url: URL(string: "https://avatars.githubusercontent.com/u/12345678")!,
            size: 60
        )
    }
    .padding()
    .background(.ultraThinMaterial)
}
#endif 
