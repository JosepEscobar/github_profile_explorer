#if os(iOS)
import SwiftUI

struct iPadOSRepositoryListView: View {
    let repositories: [Repository]
    var onSelectRepository: (Repository) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            if repositories.isEmpty {
                ContentUnavailableView("No se encontraron repositorios", systemImage: "magnifyingglass")
            } else {
                ForEach(repositories) { repository in
                    RepositoryItemView(repository: repository) { selectedRepo in
                        onSelectRepository(selectedRepo)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.primary.opacity(0.05))
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.05), radius: 3)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    iPadOSRepositoryListView(
        repositories: Repository.mockArray(),
        onSelectRepository: { _ in }
    )
}
#endif 