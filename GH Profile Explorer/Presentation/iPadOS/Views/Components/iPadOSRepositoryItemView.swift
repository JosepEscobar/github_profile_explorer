#if os(iOS)
import SwiftUI

struct iPadOSRepositoryItemView: View {
    private enum Constants {
        enum Layout {
            static let mainSpacing: CGFloat = 8
            static let descriptionSpacing: CGFloat = 2
            static let infoSpacing: CGFloat = 8
            static let topicSpacing: CGFloat = 6
            static let iconSize: CGFloat = 24
            static let iconImageSize: CGFloat = 18
            static let verticalPadding: CGFloat = 8
            static let descriptionPadding: CGFloat = 24
            static let topicPadding: CGFloat = 24
            static let topicHorizontalPadding: CGFloat = 6
            static let topicVerticalPadding: CGFloat = 2
            static let languageIndicatorSize: CGFloat = 8
            static let topicCornerRadius: CGFloat = 4
            static let maxTopicsToShow: Int = 3
        }
        
        enum Typography {
            static let iconWeight = Font.Weight.medium
            static let languageFont = Font.footnote
            static let countersFont = Font.footnote
            static let topicFont = Font.system(size: 10)
            static let remainingTopicsFont = Font.system(size: 10)
        }
        
        enum Colors {
            static let forkedIcon = Color.orange
            static let normalIcon = Color.blue
            static let secondaryText = Color.secondary
            static let primaryText = Color.primary
            static let topicBackground = Color.blue.opacity(0.1)
            static let topicText = Color.blue
            static let remainingTopicsText = Color.gray
        }
        
        enum Images {
            static let forkedRepo = "tuningfork"
            static let normalRepo = "book.closed"
            static let star = "star.fill"
        }
        
        enum Strings {
            static let additionalTopicsPrefix = "+"
        }
    }
    
    private let repository: RepositoryUIModel
    private let onTap: (RepositoryUIModel) -> Void
    
    init(
        repository: RepositoryUIModel,
        onTap: @escaping (RepositoryUIModel) -> Void = { _ in }
    ) {
        self.repository = repository
        self.onTap = onTap
    }
    
    var body: some View {
        Button {
            onTap(repository)
        } label: {
            VStack(alignment: .leading, spacing: Constants.Layout.mainSpacing) {
                HStack {
                    // Repository icon
                    Image(systemName: repository.isForked ? Constants.Images.forkedRepo : Constants.Images.normalRepo)
                        .foregroundColor(repository.isForked ? Constants.Colors.forkedIcon : Constants.Colors.normalIcon)
                        .font(.system(size: Constants.Layout.iconImageSize, weight: Constants.Typography.iconWeight))
                        .frame(width: Constants.Layout.iconSize, height: Constants.Layout.iconSize)
                    
                    VStack(alignment: .leading, spacing: Constants.Layout.descriptionSpacing) {
                        Text(repository.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(Constants.Colors.primaryText)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: Constants.Layout.infoSpacing) {
                        // Stars
                        Label(repository.stars, systemImage: Constants.Images.star)
                            .font(Constants.Typography.countersFont)
                            .foregroundColor(Constants.Colors.secondaryText)
                        
                        // Forks
                        if repository.forks != "0" {
                            Label(repository.forks, systemImage: Constants.Images.forkedRepo)
                                .font(Constants.Typography.countersFont)
                                .foregroundColor(Constants.Colors.secondaryText)
                        }
                    }
                }
                
                if let description = repository.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(Constants.Colors.secondaryText)
                        .lineLimit(2)
                        .padding(.leading, Constants.Layout.descriptionPadding)
                }
                
                HStack(spacing: Constants.Layout.mainSpacing) {
                    // Language indicator
                    if let language = repository.language {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(LanguageColorUtils.color(for: language))
                                .frame(width: Constants.Layout.languageIndicatorSize, height: Constants.Layout.languageIndicatorSize)
                            Text(language)
                                .font(Constants.Typography.languageFont)
                                .foregroundColor(Constants.Colors.secondaryText)
                        }
                    }
                    
                    // Topics
                    if !repository.topics.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Constants.Layout.topicSpacing) {
                                ForEach(repository.topics.prefix(Constants.Layout.maxTopicsToShow), id: \.self) { topic in
                                    Text(topic)
                                        .font(Constants.Typography.topicFont)
                                        .foregroundColor(Constants.Colors.topicText)
                                        .padding(.horizontal, Constants.Layout.topicHorizontalPadding)
                                        .padding(.vertical, Constants.Layout.topicVerticalPadding)
                                        .background(Constants.Colors.topicBackground)
                                        .cornerRadius(Constants.Layout.topicCornerRadius)
                                }
                                
                                if repository.topics.count > Constants.Layout.maxTopicsToShow {
                                    Text(Constants.Strings.additionalTopicsPrefix + "\(repository.topics.count - Constants.Layout.maxTopicsToShow)")
                                        .font(Constants.Typography.remainingTopicsFont)
                                        .foregroundColor(Constants.Colors.remainingTopicsText)
                                }
                            }
                        }
                        .padding(.leading, Constants.Layout.topicPadding)
                    }
                }
            }
            .padding(.vertical, Constants.Layout.verticalPadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        iPadOSRepositoryItemView(repository: RepositoryUIModel.mock())
            .padding()
            .background(Color.secondary.opacity(0.05))
    }
    .padding()
}
#endif 