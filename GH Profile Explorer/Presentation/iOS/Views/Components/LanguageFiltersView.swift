#if os(iOS)
import SwiftUI

struct LanguageFiltersView: View {
    let languages: [String]
    @Binding var selectedLanguage: String?
    
    private enum Constants {
        enum Keys {
            static let allFilters = "all_languages"
        }
        
        enum Images {
            static let checkmark = "checkmark"
        }
        
        enum Layout {
            static let itemSpacing: CGFloat = 8
            static let horizontalPadding: CGFloat = 12
            static let verticalPadding: CGFloat = 6
            static let indicatorSize: CGFloat = 8
            static let cornerRadius: CGFloat = 8
            static let containerPadding: CGFloat = 16
            static let negativeContainerPadding: CGFloat = -16
        }
        
        enum Colors {
            static let selected = Color.blue
            static let unselected = Color.secondary.opacity(0.1)
            static let selectedText = Color.white
            static let unselectedText = Color.primary
        }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Constants.Layout.itemSpacing) {
                Button {
                    selectedLanguage = nil
                } label: {
                    HStack {
                        Text(Constants.Keys.allFilters.localized)
                        if selectedLanguage == nil {
                            Image(systemName: Constants.Images.checkmark)
                        }
                    }
                    .padding(.horizontal, Constants.Layout.horizontalPadding)
                    .padding(.vertical, Constants.Layout.verticalPadding)
                    .background(selectedLanguage == nil ? Constants.Colors.selected : Constants.Colors.unselected)
                    .foregroundColor(selectedLanguage == nil ? Constants.Colors.selectedText : Constants.Colors.unselectedText)
                    .cornerRadius(Constants.Layout.cornerRadius)
                }
                
                ForEach(languages, id: \.self) { language in
                    Button {
                        selectedLanguage = language
                    } label: {
                        HStack {
                            Circle()
                                .fill(LanguageColorUtils.color(for: language))
                                .frame(width: Constants.Layout.indicatorSize, height: Constants.Layout.indicatorSize)
                            
                            Text(language)
                            
                            if selectedLanguage == language {
                                Image(systemName: Constants.Images.checkmark)
                            }
                        }
                        .padding(.horizontal, Constants.Layout.horizontalPadding)
                        .padding(.vertical, Constants.Layout.verticalPadding)
                        .background(selectedLanguage == language ? Constants.Colors.selected : Constants.Colors.unselected)
                        .foregroundColor(selectedLanguage == language ? Constants.Colors.selectedText : Constants.Colors.unselectedText)
                        .cornerRadius(Constants.Layout.cornerRadius)
                    }
                }
            }
            .padding(.leading, Constants.Layout.containerPadding)
            .padding(.trailing, Constants.Layout.containerPadding)
        }
        .padding(.horizontal, Constants.Layout.negativeContainerPadding)
    }
}

#Preview {
    LanguageFiltersView(
        languages: ["Swift", "JavaScript", "Python", "HTML", "CSS"],
        selectedLanguage: .constant("Swift")
    )
    .padding()
}
#endif 