#if os(macOS)
import SwiftUI
import Charts

struct MacOSLanguageStatsView: View {
    private enum Constants {
        enum Layout {
            static let barHeight: CGFloat = 40
            static let padding: CGFloat = 20
        }
        
        enum Strings {
            static let noStatsAvailable = "no_stats_available".localized
            static let languageDistribution = "language_distribution".localized
            static let totalRepositories = "total_repositories".localized
        }
        
        enum Images {
            static let noStats = "chart.bar.xaxis"
        }
    }
    
    let languageStats: [LanguageStatUIModel]
    
    var body: some View {
        VStack {
            if languageStats.isEmpty {
                ContentUnavailableView(
                    Constants.Strings.noStatsAvailable, 
                    systemImage: Constants.Images.noStats
                )
            } else {
                VStack(alignment: .leading) {
                    Text(Constants.Strings.languageDistribution)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    
                    Chart(languageStats) { stat in
                        BarMark(
                            x: .value("Cantidad", stat.count),
                            y: .value("Lenguaje", stat.language)
                        )
                        .foregroundStyle(LanguageColorUtils.color(for: stat.language))
                    }
                    .chartXAxis(.hidden)
                    .frame(height: CGFloat(languageStats.count * Int(Constants.Layout.barHeight)))
                    .padding()
                    
                    // Lista de lenguajes con sus colores correspondientes
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(languageStats) { stat in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(LanguageColorUtils.color(for: stat.language))
                                    .frame(width: 12, height: 12)
                                
                                Text(stat.language)
                                    .font(.body)
                                
                                Spacer()
                                
                                Text("\(stat.count)")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Text("\(Constants.Strings.totalRepositories): \(languageStats.reduce(0) { $0 + $1.count })")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding(.top)
                }
                .padding(Constants.Layout.padding)
            }
        }
    }
}

#Preview {
    MacOSLanguageStatsView(
        languageStats: [
            LanguageStatUIModel(language: "Swift", count: 15),
            LanguageStatUIModel(language: "JavaScript", count: 10),
            LanguageStatUIModel(language: "Python", count: 5)
        ]
    )
}

#endif 