#if os(visionOS)
import SwiftUI

struct VisionOSRepositoryDetailView: View {
    private enum Constants {
        enum Layout {
            static let spacing: CGFloat = 20
            static let dividerSpacing: CGFloat = 20
            static let sectionSpacing: CGFloat = 10
            static let contentPadding: CGFloat = 24
            static let cornerRadius: CGFloat = 12
            static let statsSpacing: CGFloat = 20
        }
        
        enum Colors {
            static let icon = Color.secondary
            static let buttonBackground = Color.blue
            static let buttonText = Color.white
            static let star = Color.yellow
            static let fork = Color.green
            static let watch = Color.blue
        }
        
        enum Images {
            static let close = "xmark.circle.fill"
            static let browser = "safari"
            static let star = "star.fill"
            static let fork = "tuningfork"
            static let watch = "eye.fill"
        }
        
        enum Strings {
            static let viewOnGitHub = "view_on_github"
            static let created = "created"
            static let updated = "updated"
            static let stars = "stars"
            static let forks = "forks"
            static let watchers = "watchers"
        }
    }
    
    let repository: RepositoryUIModel
    let openURL: (URL) -> Void
    @Environment(\.dismiss) private var dismiss
    
    // Fechas estáticas para simular creación y actualización
    private let createdDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
    private let updatedDate = Date()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Constants.Layout.spacing) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text(repository.name)
                            .font(.largeTitle.bold())
                        
                        if let language = repository.language {
                            HStack {
                                Circle()
                                    .fill(LanguageColorUtils.color(for: language))
                                    .frame(width: 12, height: 12)
                                Text(language)
                                    .font(.headline)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: Constants.Images.close)
                            .font(.title2)
                            .foregroundColor(Constants.Colors.icon)
                    }
                    .buttonStyle(.plain)
                }
                
                Divider()
                    .padding(.vertical, Constants.Layout.dividerSpacing)
                
                // Description
                if let description = repository.description, !description.isEmpty {
                    Text(description)
                        .font(.title3)
                }
                
                // Stats
                HStack(spacing: Constants.Layout.statsSpacing) {
                    VisionOSStatView(
                        value: repository.stars, 
                        label: NSLocalizedString(Constants.Strings.stars, comment: ""), 
                        icon: Constants.Images.star, 
                        color: Constants.Colors.star
                    )
                    
                    VisionOSStatView(
                        value: repository.forks, 
                        label: NSLocalizedString(Constants.Strings.forks, comment: ""), 
                        icon: Constants.Images.fork, 
                        color: Constants.Colors.fork
                    )
                    
                    VisionOSStatView(
                        value: repository.watchers, 
                        label: NSLocalizedString(Constants.Strings.watchers, comment: ""), 
                        icon: Constants.Images.watch, 
                        color: Constants.Colors.watch
                    )
                }
                .padding(.vertical)
                
                // Dates
                VStack(alignment: .leading, spacing: Constants.Layout.sectionSpacing) {
                    VisionOSDateInfoRow(
                        label: NSLocalizedString(Constants.Strings.created, comment: ""), 
                        date: createdDate
                    )
                    
                    VisionOSDateInfoRow(
                        label: NSLocalizedString(Constants.Strings.updated, comment: ""), 
                        date: updatedDate
                    )
                }
                .padding(.vertical)
                
                Divider()
                    .padding(.vertical, Constants.Layout.dividerSpacing)
                
                // Open in GitHub button
                Button {
                    openURL(repository.htmlURL)
                } label: {
                    HStack {
                        Image(systemName: Constants.Images.browser)
                        Text(NSLocalizedString(Constants.Strings.viewOnGitHub, comment: ""))
                    }
                    .font(.headline)
                    .foregroundColor(Constants.Colors.buttonText)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Constants.Colors.buttonBackground)
                    .cornerRadius(Constants.Layout.cornerRadius)
                }
                .hoverEffect(.highlight)
            }
            .padding(Constants.Layout.contentPadding)
        }
    }
}

// Componente para mostrar estadísticas del repositorio
struct VisionOSStatView: View {
    private enum Constants {
        enum Layout {
            static let spacing: CGFloat = 8
            static let cornerRadius: CGFloat = 12
            static let contentPadding: CGFloat = 16
        }
        
        enum Colors {
            static let text = Color.secondary
        }
    }
    
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Constants.Layout.spacing) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2.bold())
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(Constants.Colors.text)
        }
        .frame(maxWidth: .infinity)
        .padding(Constants.Layout.contentPadding)
        .background(.ultraThinMaterial)
        .cornerRadius(Constants.Layout.cornerRadius)
    }
}

// Componente para mostrar información de fechas
struct VisionOSDateInfoRow: View {
    private enum Constants {
        enum Colors {
            static let label = Color.secondary
        }
    }
    
    let label: String
    let date: Date
    
    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(Constants.Colors.label)
            
            Spacer()
            
            Text(date.formatted(date: .long, time: .shortened))
                .font(.headline)
        }
    }
}

#Preview {
    VisionOSRepositoryDetailView(
        repository: RepositoryUIModel.mock(),
        openURL: { _ in }
    )
    .padding()
}
#endif 