#if os(iOS)
import SwiftUI

struct iPadOSStatView: View {
    let count: Int
    let title: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
            
            Text("\(count)")
                .font(.headline)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    HStack {
        iPadOSStatView(count: 120, title: "Seguidores", icon: "person.2")
        iPadOSStatView(count: 50, title: "Siguiendo", icon: "person.badge.plus")
        iPadOSStatView(count: 35, title: "Repos", icon: "book.closed")
    }
    .padding()
}
#endif 