#if os(iOS)
import SwiftUI

struct iPadOSRepositorySearchView: View {
    private enum Constants {
        enum Layout {
            static let padding: CGFloat = 8
            static let cornerRadius: CGFloat = 8
        }
        
        enum Colors {
            static let background = Color.secondary.opacity(0.1)
            static let containerBackground = Color.primary.opacity(0.05)
            static let secondary = Color.secondary
        }
        
        enum Typography {
            static let backButtonFont = Font.subheadline
        }
        
        enum Images {
            static let search = "magnifyingglass"
            static let clear = "xmark.circle.fill"
        }
        
        enum Strings {
            static let placeholder = "search_repository_placeholder".localized
            static let backToList = "back_to_list".localized
        }
    }
    
    @Binding var searchQuery: String
    var isRepositorySelected: Bool
    var onClearSelection: () -> Void
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: Constants.Images.search)
                    .foregroundColor(Constants.Colors.secondary)
                
                TextField(Constants.Strings.placeholder, text: $searchQuery)
                    .textFieldStyle(.plain)
                
                if !searchQuery.isEmpty {
                    Button {
                        searchQuery = ""
                    } label: {
                        Image(systemName: Constants.Images.clear)
                            .foregroundColor(Constants.Colors.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(Constants.Layout.padding)
            .background(Constants.Colors.background)
            .cornerRadius(Constants.Layout.cornerRadius)
            
            if isRepositorySelected {
                Button {
                    onClearSelection()
                } label: {
                    Text(Constants.Strings.backToList)
                        .font(Constants.Typography.backButtonFont)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Constants.Colors.containerBackground)
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