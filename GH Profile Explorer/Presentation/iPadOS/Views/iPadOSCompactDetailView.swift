#if os(iOS)
import SwiftUI

struct iPadOSCompactDetailView: View {
    private enum Constants {
        enum Layout {
            static let spacing: CGFloat = 20
            static let repositoriesHeightRatio: CGFloat = 0.6
        }
    }
    
    let user: UserUIModel
    let repositories: [RepositoryUIModel]
    let geometry: GeometryProxy
    var onOpenInSafari: (String) -> Void
    var onSelectRepository: (RepositoryUIModel) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: Constants.Layout.spacing) {
                iPadOSProfileHeaderView(
                    user: user,
                    onOpenInSafari: onOpenInSafari
                )
                
                iPadOSRepositoryListView(
                    repositories: repositories,
                    onSelectRepository: onSelectRepository
                )
                .frame(height: geometry.size.height * Constants.Layout.repositoriesHeightRatio)
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    GeometryReader { geometry in
        iPadOSCompactDetailView(
            user: UserUIModel.mock(),
            repositories: RepositoryUIModel.mockArray(),
            geometry: geometry,
            onOpenInSafari: { _ in },
            onSelectRepository: { _ in }
        )
    }
}

#endif 