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
                // Calculamos las filas manualmente
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
        
        // No podemos medir vistas reales en tiempo de compilación,
        // así que usamos una estimación
        let estimatedItemWidth: CGFloat = FlowLayoutConstants.Layout.estimatedItemWidth + spacing 
        
        for item in items {
            // Si no cabe en la fila actual, crear una nueva
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
