#if os(tvOS)
import SwiftUI

struct TVOSRepositoriesView: View {
    private enum Constants {
        enum Strings {
            static let repositories = "repositories"
            static let viewOnGitHub = "view_on_github"
            static let noDescription = "no_description"
        }
        
        enum Layout {
            static let spacing: CGFloat = 25
            static let itemSpacing: CGFloat = 10
            static let nameSize: CGFloat = 38
            static let detailSpacing: CGFloat = 60
            static let languageIndicatorSize: CGFloat = 18
            static let detailContentPadding: CGFloat = 40
            static let detailCornerRadius: CGFloat = 20
            static let gridSpacing: CGFloat = 30
            static let topPadding: CGFloat = 10
            static let cardWidth: CGFloat = 320
            static let cardHeight: CGFloat = 200
            static let cardPadding: CGFloat = 20
            static let cardCornerRadius: CGFloat = 16
            static let languageItemSize: CGFloat = 12
            static let topicsSpacing: CGFloat = 15
            static let topicPaddingH: CGFloat = 15
            static let topicPaddingV: CGFloat = 8
            static let topicCornerRadius: CGFloat = 16
            static let topicBorderWidth: CGFloat = 2
        }
        
        enum Colors {
            static let detailBackground = Color.black.opacity(0.4)
            static let detailStroke = Color.gray.opacity(0.3)
            static let descriptionText = Color.white
            static let languageText = Color.gray
            static let starIcon = Color.yellow
            static let forkIcon = Color.gray
            static let watcherIcon = Color.gray
            static let backgroundSelected = Color.blue.opacity(0.3)
            static let backgroundUnselected = Color.black.opacity(0.4)
            static let topicBackground = Color.blue.opacity(0.3)
            static let topicBorder = Color.blue.opacity(0.6)
            static let topicText = Color.white
            static let repositoryForkIcon = Color.orange
            static let repositoryIcon = Color.blue
        }
        
        enum Images {
            static let star = "star.fill"
            static let fork = "tuningfork"
            static let watch = "eye.fill"
            static let repository = "book.closed"
        }
    }
    
    let repositories: [RepositoryUIModel]
    @State private var selectedRepository: RepositoryUIModel?
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            if let selected = selectedRepository {
                // Repository detail
                repositoryDetailView(for: selected)
            }
            
            // Repository list
            Text(Constants.Strings.repositories.localized.uppercased())
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.top, Constants.Layout.topPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Constants.Layout.gridSpacing) {
                    ForEach(repositories) { repo in
                        repositoryCardView(for: repo)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
        }
        .onAppear {
            if let first = repositories.first {
                selectedRepository = first
            }
        }
    }
    
    private func repositoryDetailView(for repository: RepositoryUIModel) -> some View {
        VStack(spacing: Constants.Layout.spacing) {
            VStack(spacing: Constants.Layout.itemSpacing) {
                Text(repository.name)
                    .font(.system(size: Constants.Layout.nameSize))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                if let language = repository.language {
                    HStack {
                        Circle()
                            .fill(LanguageColorUtils.color(for: language))
                            .frame(width: Constants.Layout.languageIndicatorSize, height: Constants.Layout.languageIndicatorSize)
                        
                        Text(language)
                            .font(.title2)
                            .foregroundColor(Constants.Colors.languageText)
                    }
                }
            }
            
            if let description = repository.description, !description.isEmpty {
                Text(description)
                    .font(.title2)
                    .foregroundColor(Constants.Colors.descriptionText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 80)
            }
            
            HStack(spacing: Constants.Layout.detailSpacing) {
                Label(repository.stars, systemImage: Constants.Images.star)
                    .foregroundColor(Constants.Colors.starIcon)
                
                Label(repository.forks, systemImage: Constants.Images.fork)
                    .foregroundColor(Constants.Colors.forkIcon)
                
                Label(repository.watchers, systemImage: Constants.Images.watch)
                    .foregroundColor(Constants.Colors.watcherIcon)
            }
            .font(.title2)
            .padding(.top)
            
            if !repository.topics.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Constants.Layout.topicsSpacing) {
                        ForEach(repository.topics, id: \.self) { topic in
                            Text(topic)
                                .font(.headline)
                                .foregroundColor(Constants.Colors.topicText)
                                .padding(.horizontal, Constants.Layout.topicPaddingH)
                                .padding(.vertical, Constants.Layout.topicPaddingV)
                                .background(
                                    RoundedRectangle(cornerRadius: Constants.Layout.topicCornerRadius)
                                        .fill(Constants.Colors.topicBackground)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: Constants.Layout.topicCornerRadius)
                                                .stroke(Constants.Colors.topicBorder, lineWidth: Constants.Layout.topicBorderWidth)
                                        )
                                )
                        }
                    }
                }
                .padding(.top)
            }
            
            Button(Constants.Strings.viewOnGitHub.localized) {
                // Would show QR code in real implementation
            }
            .buttonStyle(TVFocusableButtonStyle(color: Color.blue))
            .padding(.top, 30)
        }
        .padding(Constants.Layout.detailContentPadding)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: Constants.Layout.detailCornerRadius)
                .fill(Constants.Colors.detailBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.Layout.detailCornerRadius)
                        .stroke(Constants.Colors.detailStroke, lineWidth: 2)
                )
        )
        .padding()
    }
    
    private func repositoryCardView(for repository: RepositoryUIModel) -> some View {
        Button {
            selectedRepository = repository
        } label: {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Image(systemName: repository.isForked ? Constants.Images.fork : Constants.Images.repository)
                        .foregroundColor(repository.isForked ? Constants.Colors.repositoryForkIcon : Constants.Colors.repositoryIcon)
                        .font(.title2)
                    
                    Text(repository.name)
                        .lineLimit(1)
                        .foregroundColor(.white)
                        .font(.title3)
                }
                
                if let description = repository.description, !description.isEmpty {
                    Text(description)
                        .lineLimit(2)
                        .font(.body)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                HStack {
                    if let language = repository.language {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(LanguageColorUtils.color(for: language))
                                .frame(width: Constants.Layout.languageItemSize, height: Constants.Layout.languageItemSize)
                            
                            Text(language)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    Label(repository.stars, systemImage: Constants.Images.star)
                        .font(.subheadline)
                        .foregroundColor(.yellow)
                }
            }
            .padding(Constants.Layout.cardPadding)
            .frame(width: Constants.Layout.cardWidth, height: Constants.Layout.cardHeight)
            .background(
                RoundedRectangle(cornerRadius: Constants.Layout.cardCornerRadius)
                    .fill(selectedRepository?.id == repository.id ? 
                          Constants.Colors.backgroundSelected : 
                          Constants.Colors.backgroundUnselected)
            )
        }
        .buttonStyle(TVFocusableButtonStyle())
        .focused($isFocused)
    }
}

#Preview {
    TVOSRepositoriesView(repositories: RepositoryUIModel.mockArray())
}
#endif 
