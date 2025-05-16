#if os(iOS)
import SwiftUI

struct iPadOSRegularDetailView: View {
    private enum Constants {
        enum Layout {
            static let detailWidthRatioExpanded = 0.5
            static let detailWidthRatioCollapsed = 0.4
            static let detailWidthMaxExpanded = 600.0
            static let detailWidthMaxCollapsed = 500.0
        }
        
        enum Colors {
            static let background = Color.primary.opacity(0.03)
        }
    }
    
    let user: UserUIModel
    let filteredRepositories: [RepositoryUIModel]
    let selectedRepository: RepositoryUIModel?
    let isDetailExpanded: Bool
    let searchQuery: Binding<String>
    let geometry: GeometryProxy
    var onToggleExpand: () -> Void
    var onOpenInSafari: (String) -> Void
    var onShowQRCode: () -> Void
    var onSelectRepository: (RepositoryUIModel) -> Void
    var onOpenRepository: (RepositoryUIModel) -> Void
    var onClearSelection: () -> Void
    
    var body: some View {
        GeometryReader { detailGeometry in
            HStack(spacing: 0) {
                // Perfil (izquierda)
                ScrollView {
                    iPadOSProfileDetailView(
                        user: user,
                        isDetailExpanded: isDetailExpanded,
                        onToggleExpand: onToggleExpand,
                        onOpenInSafari: onOpenInSafari,
                        onShowQRCode: onShowQRCode
                    )
                }
                .frame(width: isDetailExpanded 
                       ? min(detailGeometry.size.width * Constants.Layout.detailWidthRatioExpanded, Constants.Layout.detailWidthMaxExpanded) 
                       : min(detailGeometry.size.width * Constants.Layout.detailWidthRatioCollapsed, Constants.Layout.detailWidthMaxCollapsed))
                .background(Constants.Colors.background)
                
                Divider()
                
                // Repositorios (derecha)
                VStack(spacing: 0) {
                    iPadOSRepositorySearchView(
                        searchQuery: searchQuery,
                        isRepositorySelected: selectedRepository != nil,
                        onClearSelection: onClearSelection
                    )
                    
                    if let repository = selectedRepository {
                        iPadOSRepositoryDetailView(
                            repository: repository,
                            onOpenRepository: onOpenRepository
                        )
                    } else {
                        iPadOSRepositoryListView(
                            repositories: filteredRepositories,
                            onSelectRepository: onSelectRepository
                        )
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    GeometryReader { geometry in
        iPadOSRegularDetailView(
            user: UserUIModel.mock(),
            filteredRepositories: RepositoryUIModel.mockArray(),
            selectedRepository: nil,
            isDetailExpanded: true,
            searchQuery: .constant(""),
            geometry: geometry,
            onToggleExpand: {},
            onOpenInSafari: { _ in },
            onShowQRCode: {},
            onSelectRepository: { _ in },
            onOpenRepository: { _ in },
            onClearSelection: {}
        )
    }
}

#endif 