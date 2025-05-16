#if os(visionOS)
import SwiftUI

struct VisionOSRepositoryCardView: View {
    private enum Constants {
        enum Layout {
            static let cardPadding: CGFloat = 24
            static let cardSpacing: CGFloat = 16
            static let iconSize: CGFloat = 24
            static let cornerRadius: CGFloat = 16
            static let shadowRadius: CGFloat = 5
            static let topicSpacing: CGFloat = 6
            static let topicPadding: CGFloat = 8
            static let topicCornerRadius: CGFloat = 12
            static let languageIndicatorSize: CGFloat = 10
            static let cardMinHeight: CGFloat = 200
            static let cardVerticalPadding: CGFloat = 16
            static let cardHorizontalPadding: CGFloat = 20
            static let statsSpacing: CGFloat = 12
        }
        
        enum Colors {
            static let background = Color.black.opacity(0.2)
            static let backgroundHover = Color.blue.opacity(0.1)
            static let shadow = Color.black.opacity(0.2)
            static let textPrimary = Color.white
            static let textSecondary = Color.secondary
            static let topicBackground = Color.blue.opacity(0.15)
            static let icon = Color.blue
            static let iconSecondary = Color.secondary
            static let starIcon = Color.yellow
        }
        
        enum Images {
            static let star = "star.fill"
            static let fork = "tuningfork"
            static let eye = "eye.fill"
            static let repository = "book.closed"
            static let privateRepo = "lock.fill"
        }
    }
    
    let repository: RepositoryUIModel
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Layout.cardSpacing) {
            // Header
            HStack {
                Image(systemName: repository.isForked ? Constants.Images.fork : Constants.Images.repository)
                    .font(.title3)
                    .foregroundColor(Constants.Colors.icon)
                
                Text(repository.name)
                    .font(.title3.bold())
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Spacer()
                
                if repository.isForked {
                    Image(systemName: Constants.Images.fork)
                        .foregroundColor(Constants.Colors.iconSecondary)
                        .font(.subheadline)
                }
            }
            
            // Description
            if let description = repository.description, !description.isEmpty {
                Text(description)
                    .font(.body)
                    .foregroundColor(Constants.Colors.textSecondary)
                    .lineLimit(3)
            }
            
            Spacer(minLength: 0)
            
            // Topics
            if !repository.topics.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Constants.Layout.topicSpacing) {
                        ForEach(repository.topics.prefix(3), id: \.self) { topic in
                            Text(topic)
                                .font(.caption)
                                .foregroundColor(Constants.Colors.textPrimary)
                                .padding(Constants.Layout.topicPadding)
                                .background(Constants.Colors.topicBackground)
                                .cornerRadius(Constants.Layout.topicCornerRadius)
                        }
                        
                        if repository.topics.count > 3 {
                            Text("+\(repository.topics.count - 3)")
                                .font(.caption)
                                .foregroundColor(Constants.Colors.textPrimary)
                                .padding(Constants.Layout.topicPadding)
                                .background(Constants.Colors.topicBackground)
                                .cornerRadius(Constants.Layout.topicCornerRadius)
                        }
                    }
                }
            }
            
            Divider()
            
            // Footer
            HStack(spacing: Constants.Layout.statsSpacing) {
                // Language
                if let language = repository.language {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(LanguageColorUtils.color(for: language))
                            .frame(width: Constants.Layout.languageIndicatorSize, height: Constants.Layout.languageIndicatorSize)
                        
                        Text(language)
                            .font(.caption)
                            .foregroundColor(Constants.Colors.textSecondary)
                    }
                }
                
                Spacer()
                
                // Stats
                HStack(spacing: Constants.Layout.statsSpacing) {
                    Label(repository.stars, systemImage: Constants.Images.star)
                        .font(.caption)
                        .foregroundColor(Constants.Colors.starIcon)
                    
                    Label(repository.forks, systemImage: Constants.Images.fork)
                        .font(.caption)
                        .foregroundColor(Constants.Colors.iconSecondary)
                }
            }
        }
        .padding(.vertical, Constants.Layout.cardVerticalPadding)
        .padding(.horizontal, Constants.Layout.cardHorizontalPadding)
        .frame(minHeight: Constants.Layout.cardMinHeight)
        .background(
            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                .fill(isHovered ? Constants.Colors.backgroundHover : Constants.Colors.background)
                .shadow(color: Constants.Colors.shadow, radius: Constants.Layout.shadowRadius)
        )
        .hoverEffect(.lift)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

#Preview {
    VisionOSRepositoryCardView(repository: RepositoryUIModel.mock())
        .frame(width: 350)
        .padding()
}
#endif 