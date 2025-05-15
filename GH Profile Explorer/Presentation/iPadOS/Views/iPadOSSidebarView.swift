#if os(iOS)
import SwiftUI

struct iPadOSSidebarView: View {
    private enum Constants {
        enum Layout {
            static let avatarSize: CGFloat = 40
            static let avatarCornerRadius: CGFloat = 20
            static let verticalPadding: CGFloat = 4
        }
        
        enum Colors {
            static let secondary = Color.secondary
            static let blue = Color.blue
        }
        
        enum Typography {
            static let headline = Font.headline
            static let caption = Font.caption
        }
        
        enum Images {
            static let search = "magnifyingglass"
            static let history = "clock"
            static let checkmark = "checkmark"
            static let trash = "trash"
            static let safari = "safari"
        }
        
        enum Strings {
            static let searchSection = "search".localized
            static let searchPlaceholder = "search_placeholder".localized
            static let searchButton = "search_button".localized
            static let historySection = "recent_searches".localized
            static let clearHistory = "clear".localized
            static let deleteHistory = "delete_history".localized
            static let currentProfile = "current_profile".localized
        }
    }
    
    @Binding var username: String
    let searchHistory: [String]
    var currentUser: UserUIModel?
    var onSearch: () -> Void
    var onSelectFromHistory: (String) -> Void
    var onClearHistory: () -> Void
    var onRemoveFromHistory: (String) -> Void
    var onOpenInSafari: (String) -> Void
    
    var body: some View {
        List {
            Section(header: Text(Constants.Strings.searchSection)) {
                SearchBarView(
                    text: $username,
                    placeholder: Constants.Strings.searchPlaceholder,
                    onSubmit: onSearch
                )
                .listRowBackground(Color.clear)
                
                Button {
                    onSearch()
                } label: {
                    Label(Constants.Strings.searchButton, systemImage: Constants.Images.search)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .disabled(username.isEmpty)
            }
            
            if !searchHistory.isEmpty {
                Section(header: HStack {
                    Text(Constants.Strings.historySection)
                    
                    Spacer()
                    
                    Button(Constants.Strings.clearHistory) {
                        onClearHistory()
                    }
                    .font(Constants.Typography.caption)
                    .foregroundColor(Constants.Colors.blue)
                }) {
                    ForEach(searchHistory, id: \.self) { historyUsername in
                        Button {
                            onSelectFromHistory(historyUsername)
                        } label: {
                            HStack {
                                Label(historyUsername, systemImage: Constants.Images.history)
                                
                                Spacer()
                                
                                if let user = currentUser, user.login == historyUsername {
                                    Image(systemName: Constants.Images.checkmark)
                                        .foregroundColor(Constants.Colors.blue)
                                }
                            }
                        }
                        #if !os(tvOS)
                        .swipeActions {
                            Button(role: .destructive) {
                                onRemoveFromHistory(historyUsername)
                            } label: {
                                Label(Constants.Strings.deleteHistory, systemImage: Constants.Images.trash)
                            }
                        }
                        #endif
                    }
                }
            }
            
            if let user = currentUser {
                Section(header: Text(Constants.Strings.currentProfile)) {
                    HStack {
                        AvatarImageView(url: user.avatarURL, size: Constants.Layout.avatarSize, cornerRadius: Constants.Layout.avatarCornerRadius)
                        
                        VStack(alignment: .leading) {
                            Text(user.name)
                                .font(Constants.Typography.headline)
                            
                            Text("@\(user.login)")
                                .font(Constants.Typography.caption)
                                .foregroundColor(Constants.Colors.secondary)
                        }
                        
                        Spacer()
                        
                        Button {
                            onOpenInSafari(user.login)
                        } label: {
                            Image(systemName: Constants.Images.safari)
                        }
                        .buttonStyle(.borderless)
                    }
                    .padding(.vertical, Constants.Layout.verticalPadding)
                }
            }
        }
        #if !os(tvOS)
        .listStyle(.sidebar)
        #else
        .listStyle(.plain)
        #endif
    }
}

#Preview {
    iPadOSSidebarView(
        username: .constant("johndoe"),
        searchHistory: ["johndoe", "janedoe", "appleseed"],
        currentUser: UserUIModel.mock(),
        onSearch: {},
        onSelectFromHistory: { _ in },
        onClearHistory: {},
        onRemoveFromHistory: { _ in },
        onOpenInSafari: { _ in }
    )
}
#endif 