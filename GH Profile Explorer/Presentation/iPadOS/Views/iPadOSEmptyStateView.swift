#if os(iOS)
import SwiftUI

struct iPadOSEmptyStateView: View {
    private enum Constants {
        enum Layout {
            static let buttonTopPadding: CGFloat = 24
        }
        
        enum Strings {
            static let searchPrompt = "search_prompt".localized
            static let searchDescription = "search_description".localized
            static let startNewSearch = "Iniciar una nueva búsqueda"
        }
        
        enum Images {
            static let search = "magnifyingglass"
        }
        
        enum Colors {
            static let searchButton = Color.accentColor
            static let searchButtonText = Color.white
        }
    }
    
    var onStartSearch: () -> Void
    
    var body: some View {
        VStack {
            ContentUnavailableView {
                Label(Constants.Strings.searchPrompt, systemImage: Constants.Images.search)
            } description: {
                Text(Constants.Strings.searchDescription)
            }
            
            Button {
                onStartSearch()
            } label: {
                Text(Constants.Strings.startNewSearch)
                    .font(.headline)
                    .foregroundColor(Constants.Colors.searchButtonText)
                    .padding()
                    .background(Constants.Colors.searchButton)
                    .cornerRadius(10)
            }
            .padding(.top, Constants.Layout.buttonTopPadding)
            .shadow(radius: 3)
        }
    }
}

#Preview {
    iPadOSEmptyStateView(onStartSearch: {})
}

#endif 