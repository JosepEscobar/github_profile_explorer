#if os(iOS)
import SwiftUI

private enum FlowLayoutConstants {
    enum Layout {
        static let defaultSpacing: CGFloat = 8
        static let estimatedItemWidth: CGFloat = 100
    }
}

struct FlowLayout<T: Hashable, V: View>: View {
    let items: [T]
    let spacing: CGFloat
    @ViewBuilder let viewBuilder: (T) -> V
    
    init(
        items: [T],
        spacing: CGFloat = FlowLayoutConstants.Layout.defaultSpacing,
        @ViewBuilder viewBuilder: @escaping (T) -> V
    ) {
        self.items = items
        self.spacing = spacing
        self.viewBuilder = viewBuilder
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: spacing) {
                // Calculate rows manually
                let rows = calculateRows(containerWidth: geometry.size.width)
                
                ForEach(0..<rows.count, id: \.self) { rowIndex in
                    HStack(spacing: spacing) {
                        ForEach(rows[rowIndex], id: \.self) { item in
                            viewBuilder(item)
                        }
                    }
                }
            }
        }
    }
    
    private func calculateRows(containerWidth: CGFloat) -> [[T]] {
        var rows: [[T]] = [[]]
        var currentRowWidth: CGFloat = 0
        
        // We can't measure real views at compile time,
        // so we use an estimation
        let estimatedItemWidth: CGFloat = FlowLayoutConstants.Layout.estimatedItemWidth + spacing 
        
        for item in items {
            // If it doesn't fit in the current row, create a new one
            if currentRowWidth + estimatedItemWidth > containerWidth {
                rows.append([item])
                currentRowWidth = estimatedItemWidth
            } else {
                rows[rows.count - 1].append(item)
                currentRowWidth += estimatedItemWidth
            }
        }
        
        return rows
    }
}
#endif 
