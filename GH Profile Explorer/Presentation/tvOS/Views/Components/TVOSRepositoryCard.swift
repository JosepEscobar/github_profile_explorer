#if os(tvOS)
import SwiftUI

struct TVOSRepositoryCard: View {
    private enum Constants {
        enum Layout {
            static let height: CGFloat = 220
            static let cornerRadius: CGFloat = 16
            static let borderWidth: CGFloat = 2
            static let focusedBorderWidth: CGFloat = 4
            static let iconSize: CGFloat = 24
            static let spacing: CGFloat = 15
            static let contentPadding: CGFloat = 20
            static let languageIndicatorSize: CGFloat = 12
            static let focusedScale: CGFloat = 1.05
            static let shadowRadius: CGFloat = 10
        }
        
        enum Colors {
            static let background = Color(red: 0.08, green: 0.12, blue: 0.2)
            static let title = Color.white
            static let description = Color.white.opacity(0.8)
            static let border = Color.blue.opacity(0.4)
            static let focusedBorder = Color.white
            static let shadow = Color.blue.opacity(0.6)
            static let icon = Color.blue
            static let forkedIcon = Color.orange
            static let languageText = Color.gray.opacity(0.8)
            static let starIcon = Color.yellow
            static let starValue = Color.white.opacity(0.9)
        }
        
        enum Images {
            static let repository = "book.closed"
            static let fork = "tuningfork"
            static let star = "star.fill"
        }
    }
    
    let id: String
    let name: String
    let description: String
    let language: String?
    let languageColor: Color
    let stars: Int
    let isForked: Bool
    let isFocused: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Constants.Layout.spacing) {
                // Encabezado del repositorio
                HStack {
                    Image(systemName: isForked ? Constants.Images.fork : Constants.Images.repository)
                        .foregroundColor(isForked ? Constants.Colors.forkedIcon : Constants.Colors.icon)
                        .font(.title2)
                    
                    Text(name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Constants.Colors.title)
                        .lineLimit(1)
                }
                
                // Descripción
                Text(description)
                    .font(.body)
                    .foregroundColor(Constants.Colors.description)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                // Footer del repositorio
                HStack {
                    if let language = language {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(languageColor)
                                .frame(width: Constants.Layout.languageIndicatorSize, height: Constants.Layout.languageIndicatorSize)
                            
                            Text(language)
                                .font(.subheadline)
                                .foregroundColor(Constants.Colors.languageText)
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Image(systemName: Constants.Images.star)
                            .foregroundColor(Constants.Colors.starIcon)
                            .font(.system(size: Constants.Layout.iconSize))
                        
                        Text("\(stars)")
                            .font(.subheadline)
                            .foregroundColor(Constants.Colors.starValue)
                    }
                }
            }
            .padding(Constants.Layout.contentPadding)
            .frame(maxWidth: .infinity)
            .frame(height: Constants.Layout.height)
            .background(
                RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                    .fill(Constants.Colors.background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                    .stroke(
                        isFocused ? Constants.Colors.focusedBorder : Constants.Colors.border,
                        lineWidth: isFocused ? Constants.Layout.focusedBorderWidth : Constants.Layout.borderWidth
                    )
            )
            .scaleEffect(isFocused ? Constants.Layout.focusedScale : 1.0)
            .shadow(
                color: isFocused ? Constants.Colors.shadow : .clear,
                radius: Constants.Layout.shadowRadius
            )
            .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
        .buttonStyle(.tvCard)
    }
}

// MARK: - Vista de previsualización
#Preview {
    HStack(spacing: 20) {
        TVOSRepositoryCard(
            id: "1",
            name: "swift",
            description: "The Swift Programming Language",
            language: "Swift",
            languageColor: .orange,
            stars: 63024,
            isForked: false,
            isFocused: false,
            action: {}
        )
        
        TVOSRepositoryCard(
            id: "2",
            name: "swift-evolution",
            description: "This maintains proposals for changes and user-visible enhancements to the Swift Programming Language.",
            language: "Markdown",
            languageColor: .blue,
            stars: 14302,
            isForked: true,
            isFocused: true,
            action: {}
        )
    }
    .padding()
    .background(Color.black)
}
#endif 