#if os(visionOS)
import SwiftUI

struct VisionOSLanguageFilterView: View {
    private enum Constants {
        enum Strings {
            static let allLanguages = "all_languages"
        }
        
        enum Layout {
            static let spacing: CGFloat = 12
            static let itemSpacing: CGFloat = 4
            static let horizontalPadding: CGFloat = 16
            static let verticalPadding: CGFloat = 10
            static let cornerRadius: CGFloat = 20
            static let indicatorSize: CGFloat = 10
        }
        
        enum Colors {
            static let selected = Color.blue
            static let unselected = Color.black.opacity(0.1)
            static let selectedText = Color.white
            static let unselectedText = Color.primary
            static let checkmark = Color.white
        }
        
        enum Images {
            static let checkmark = "checkmark"
        }
    }
    
    let languages: [String]
    @Binding var selectedLanguage: String?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Constants.Layout.spacing) {
                // "All languages" button
                Button {
                    selectedLanguage = nil
                } label: {
                    HStack(spacing: Constants.Layout.itemSpacing) {
                        Text(Constants.Strings.allLanguages.localized)
                            .font(.callout)
                        
                        if selectedLanguage == nil {
                            Image(systemName: Constants.Images.checkmark)
                                .font(.caption)
                                .foregroundColor(Constants.Colors.checkmark)
                        }
                    }
                    .padding(.horizontal, Constants.Layout.horizontalPadding)
                    .padding(.vertical, Constants.Layout.verticalPadding)
                    .background(
                        Capsule()
                            .fill(selectedLanguage == nil ? Constants.Colors.selected : Constants.Colors.unselected)
                    )
                    .foregroundColor(selectedLanguage == nil ? Constants.Colors.selectedText : Constants.Colors.unselectedText)
                }
                .buttonStyle(.plain)
                .hoverEffect(.highlight)
                
                // Language buttons
                ForEach(languages, id: \.self) { language in
                    Button {
                        selectedLanguage = language
                    } label: {
                        HStack(spacing: Constants.Layout.itemSpacing) {
                            // Language color indicator
                            Circle()
                                .fill(LanguageColorUtils.color(for: language))
                                .frame(width: Constants.Layout.indicatorSize, height: Constants.Layout.indicatorSize)
                            
                            Text(language)
                                .font(.callout)
                            
                            if selectedLanguage == language {
                                Image(systemName: Constants.Images.checkmark)
                                    .font(.caption)
                                    .foregroundColor(Constants.Colors.checkmark)
                            }
                        }
                        .padding(.horizontal, Constants.Layout.horizontalPadding)
                        .padding(.vertical, Constants.Layout.verticalPadding)
                        .background(
                            Capsule()
                                .fill(selectedLanguage == language ? Constants.Colors.selected : Constants.Colors.unselected)
                        )
                        .foregroundColor(selectedLanguage == language ? Constants.Colors.selectedText : Constants.Colors.unselectedText)
                    }
                    .buttonStyle(.plain)
                    .hoverEffect(.highlight)
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    VisionOSLanguageFilterView(
        languages: ["Swift", "JavaScript", "Python", "TypeScript", "Go"],
        selectedLanguage: .constant("Swift")
    )
    .padding()
    .background(.ultraThinMaterial)
}
#endif 