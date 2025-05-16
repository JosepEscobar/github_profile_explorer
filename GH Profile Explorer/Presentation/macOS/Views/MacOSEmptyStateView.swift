#if os(macOS)
import SwiftUI

struct MacOSEmptyStateView: View {
    private enum Constants {
        enum Strings {
            static let searchPrompt = "search_prompt".localized
            static let searchDescription = "search_description".localized
        }
        
        enum Images {
            static let search = "magnifyingglass"
        }
    }
    
    var body: some View {
        ContentUnavailableView {
            Label(Constants.Strings.searchPrompt, systemImage: Constants.Images.search)
        } description: {
            Text(Constants.Strings.searchDescription)
        }
    }
}

#Preview {
    MacOSEmptyStateView()
}

#endif 