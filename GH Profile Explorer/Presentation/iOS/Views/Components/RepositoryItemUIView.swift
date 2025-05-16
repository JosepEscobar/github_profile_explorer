#if os(iOS)
import SwiftUI

struct RepositoryItemUIView: View {
    private let repository: RepositoryUIModel
    private let onTap: (RepositoryUIModel) -> Void
    
    private enum Constants {
        enum Images {
            static let repository = "book.closed"
            static let fork = "tuningfork"
            static let star = "star.fill"
        }
        
        enum Layout {
            static let itemSpacing: CGFloat = 8
            static let iconSize: CGFloat = 18
            static let iconFrame: CGFloat = 24
            static let statSpacing: CGFloat = 8
            static let descriptionPadding: CGFloat = 24
            static let languageIndicatorSize: CGFloat = 8
            static let languageSpacing: CGFloat = 4
            static let verticalPadding: CGFloat = 8
        }
        
        enum Values {
            static let zeroForks = "0"
        }
    }
    
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
            VStack(alignment: .leading, spacing: Constants.Layout.itemSpacing) {
                HStack {
                    // Repository icon
                    Image(systemName: repository.isForked ? Constants.Images.fork : Constants.Images.repository)
                        .foregroundColor(repository.isForked ? .orange : .blue)
                        .font(.system(size: Constants.Layout.iconSize, weight: .medium))
                        .frame(width: Constants.Layout.iconFrame, height: Constants.Layout.iconFrame)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(repository.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: Constants.Layout.statSpacing) {
                        // Stars
                        Label(repository.stars, systemImage: Constants.Images.star)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        // Forks
                        if repository.forks != Constants.Values.zeroForks {
                            Label(repository.forks, systemImage: Constants.Images.fork)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if let description = repository.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .padding(.leading, Constants.Layout.descriptionPadding)
                }
                
                if let language = repository.language {
                    HStack(spacing: Constants.Layout.languageSpacing) {
                        Circle()
                            .fill(LanguageColorUtils.color(for: language))
                            .frame(width: Constants.Layout.languageIndicatorSize, height: Constants.Layout.languageIndicatorSize)
                        Text(language)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.leading, Constants.Layout.descriptionPadding)
                }
            }
            .padding(.vertical, Constants.Layout.verticalPadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RepositoryItemUIView(repository: RepositoryUIModel.mock())
        .padding()
        .background(Color.secondary.opacity(0.05))
}
#endif 