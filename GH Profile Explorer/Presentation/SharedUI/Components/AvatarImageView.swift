import SwiftUI
import Kingfisher

public struct AvatarImageView: View {
    private let url: URL
    private let size: CGFloat
    private let cornerRadius: CGFloat
    
    public init(url: URL, size: CGFloat = 80, cornerRadius: CGFloat = 40) {
        self.url = url
        self.size = size
        self.cornerRadius = cornerRadius
    }
    
    public var body: some View {
        KFImage(url)
            .placeholder {
                ZStack {
                    Color.gray.opacity(0.2)
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(size * 0.25)
                        .foregroundColor(.gray)
                }
            }
            .retry(maxCount: 3, interval: .seconds(2))
            .fade(duration: 0.3)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    AvatarImageView(url: URL(string: "https://github.com/octocat.png")!)
} 