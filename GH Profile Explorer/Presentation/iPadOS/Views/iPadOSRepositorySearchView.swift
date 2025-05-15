#if os(iOS)
import SwiftUI

struct iPadOSRepositorySearchView: View {
    @Binding var searchQuery: String
    var isRepositorySelected: Bool
    var onClearSelection: () -> Void
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Buscar repositorios", text: $searchQuery)
                    .textFieldStyle(.plain)
                
                if !searchQuery.isEmpty {
                    Button {
                        searchQuery = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
            
            if isRepositorySelected {
                Button {
                    onClearSelection()
                } label: {
                    Text("Volver a la lista")
                        .font(.subheadline)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color.primary.opacity(0.05))
    }
}

#Preview {
    iPadOSRepositorySearchView(
        searchQuery: .constant("swift"),
        isRepositorySelected: true,
        onClearSelection: {}
    )
}
#endif 