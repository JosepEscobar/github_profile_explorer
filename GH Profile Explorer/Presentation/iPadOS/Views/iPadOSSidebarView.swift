#if os(iOS)
import SwiftUI

struct iPadOSSidebarView: View {
    @Binding var username: String
    let searchHistory: [String]
    var currentUser: User?
    var onSearch: () -> Void
    var onSelectFromHistory: (String) -> Void
    var onClearHistory: () -> Void
    var onRemoveFromHistory: (String) -> Void
    var onOpenInSafari: (String) -> Void
    
    var body: some View {
        List {
            Section(header: Text("Buscar")) {
                SearchBarView(
                    text: $username,
                    placeholder: "Nombre de usuario",
                    onSubmit: onSearch
                )
                .listRowBackground(Color.clear)
                
                Button {
                    onSearch()
                } label: {
                    Label("Buscar", systemImage: "magnifyingglass")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .disabled(username.isEmpty)
            }
            
            if !searchHistory.isEmpty {
                Section(header: HStack {
                    Text("Historial")
                    
                    Spacer()
                    
                    Button("Limpiar") {
                        onClearHistory()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }) {
                    ForEach(searchHistory, id: \.self) { historyUsername in
                        Button {
                            onSelectFromHistory(historyUsername)
                        } label: {
                            HStack {
                                Label(historyUsername, systemImage: "clock")
                                
                                Spacer()
                                
                                if let user = currentUser, user.login == historyUsername {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        #if !os(tvOS)
                        .swipeActions {
                            Button(role: .destructive) {
                                onRemoveFromHistory(historyUsername)
                            } label: {
                                Label("Eliminar", systemImage: "trash")
                            }
                        }
                        #endif
                    }
                }
            }
            
            if let user = currentUser {
                Section(header: Text("Perfil actual")) {
                    HStack {
                        AvatarImageView(url: user.avatarURL, size: 40, cornerRadius: 20)
                        
                        VStack(alignment: .leading) {
                            Text(user.name ?? user.login)
                                .font(.headline)
                            
                            Text("@\(user.login)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button {
                            onOpenInSafari(user.login)
                        } label: {
                            Image(systemName: "safari")
                        }
                        .buttonStyle(.borderless)
                    }
                    .padding(.vertical, 4)
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
        currentUser: User.mock(),
        onSearch: {},
        onSelectFromHistory: { _ in },
        onClearHistory: {},
        onRemoveFromHistory: { _ in },
        onOpenInSafari: { _ in }
    )
}
#endif 