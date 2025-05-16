#if os(visionOS)
import SwiftUI

struct VisionOSSearchBarSectionView: View {
    @Binding var username: String
    var onSearch: () -> Void
    var onShowHistory: () -> Void
    
    private enum Constants {
        enum Strings {
            static let search = "search"
        }
        
        enum Images {
            static let search = "magnifyingglass"
        }
    }
    
    var body: some View {
        HStack {
            VisionOSSearchBarView(
                text: $username,
                placeholder: "search_user".localized
            ) {
                onSearch()
            }
            
            Button {
                onSearch()
            } label: {
                Text(Constants.Strings.search.localized)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .keyboardShortcut(.defaultAction)
        }
        .padding()
        .background(.ultraThinMaterial)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

#Preview {
    VisionOSSearchBarSectionView(
        username: .constant("octocat"),
        onSearch: {},
        onShowHistory: {}
    )
}
#endif 
