#if os(iOS)
import SwiftUI

struct iPadOSRepositoryDetailView: View {
    private enum Constants {
        enum Layout {
            static let mainSpacing: CGFloat = 20
            static let sectionSpacing: CGFloat = 8
            static let languageIndicatorSize: CGFloat = 12
            static let statsSpacing: CGFloat = 30
            static let cornerRadius: CGFloat = 8
        }
        
        enum Colors {
            static let descriptionBackground = Color.gray.opacity(0.1)
            static let secondaryText = Color.secondary
        }
        
        enum Typography {
            static let titleFont = Font.title
            static let titleWeight = Font.Weight.bold
            static let subheadlineFont = Font.subheadline
            static let bodyFont = Font.body
            static let headlineFont = Font.headline
        }
        
        enum Images {
            static let safari = "safari"
            static let star = "star.fill"
            static let fork = "tuningfork"
            static let watchers = "eye.fill"
        }
        
        enum Strings {
            static let viewOnGitHub = "view_on_github".localized
            static let topicsTitle = "topics".localized
            static let starsTitle = "stars".localized
            static let forksTitle = "forks".localized
            static let watchersTitle = "watchers".localized
        }
    }
    
    let repository: RepositoryUIModel
    var onOpenRepository: (RepositoryUIModel) -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Constants.Layout.mainSpacing) {
                HStack {
                    VStack(alignment: .leading, spacing: Constants.Layout.sectionSpacing) {
                        Text(repository.name)
                            .font(Constants.Typography.titleFont)
                            .fontWeight(Constants.Typography.titleWeight)
                        
                        if let language = repository.language {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(LanguageColorUtils.color(for: language))
                                    .frame(width: Constants.Layout.languageIndicatorSize, height: Constants.Layout.languageIndicatorSize)
                                
                                Text(language)
                                    .font(Constants.Typography.subheadlineFont)
                                    .foregroundColor(Constants.Colors.secondaryText)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        onOpenRepository(repository)
                    } label: {
                        Label(Constants.Strings.viewOnGitHub, systemImage: Constants.Images.safari)
                    }
                    .buttonStyle(.bordered)
                }
                
                if let description = repository.description, !description.isEmpty {
                    Text(description)
                        .font(Constants.Typography.bodyFont)
                        .foregroundColor(Constants.Colors.secondaryText)
                        .padding()
                        .background(Constants.Colors.descriptionBackground)
                        .cornerRadius(Constants.Layout.cornerRadius)
                }
                
                HStack(spacing: Constants.Layout.statsSpacing) {
                    iPadOSStatView(count: repository.stars, title: Constants.Strings.starsTitle, icon: Constants.Images.star)
                    iPadOSStatView(count: repository.forks, title: Constants.Strings.forksTitle, icon: Constants.Images.fork)
                    iPadOSStatView(count: repository.watchers, title: Constants.Strings.watchersTitle, icon: Constants.Images.watchers)
                }
                .padding(.vertical)
                
                if !repository.topics.isEmpty {
                    VStack(alignment: .leading, spacing: Constants.Layout.sectionSpacing) {
                        Text(Constants.Strings.topicsTitle)
                            .font(Constants.Typography.headlineFont)
                        
                        FlowLayout(items: repository.topics) { topic in
                            Text(topic)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    iPadOSRepositoryDetailView(
        repository: RepositoryUIModel.mock(),
        onOpenRepository: { _ in }
    )
}
#endif 