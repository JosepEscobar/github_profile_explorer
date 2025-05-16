#if os(visionOS)
import SwiftUI

struct VisionOSSearchHistoryView: View {
    let searchHistory: [String]
    @Binding var isShowing: Bool
    var onSelect: (String) -> Void
    var onClearAll: () -> Void
    var onRemoveItem: (Int) -> Void
    
    private enum Constants {
        enum Strings {
            static let recentSearches = "recent_searches"
            static let clearAll = "clear_all"
            static let cancel = "cancel"
        }
        
        enum Images {
            static let clock = "clock"
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(searchHistory, id: \.self) { item in
                    Button {
                        onSelect(item)
                        isShowing = false
                    } label: {
                        HStack {
                            Image(systemName: Constants.Images.clock)
                                .foregroundColor(.secondary)
                            Text(item)
                                .foregroundColor(.primary)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        if index < searchHistory.count {
                            onRemoveItem(index)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(Constants.Strings.recentSearches.localized)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        onClearAll()
                    } label: {
                        Text(Constants.Strings.clearAll.localized)
                    }
                    .disabled(searchHistory.isEmpty)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        isShowing = false
                    } label: {
                        Text(Constants.Strings.cancel.localized)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    VisionOSSearchHistoryView(
        searchHistory: ["octocat", "microsoft", "google"],
        isShowing: .constant(true),
        onSelect: { _ in },
        onClearAll: {},
        onRemoveItem: { _ in }
    )
}
#endif 