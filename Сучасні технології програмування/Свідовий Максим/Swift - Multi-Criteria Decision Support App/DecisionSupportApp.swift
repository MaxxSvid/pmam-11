import SwiftUI

// MARK: - Моделі

enum CriterionType: String, CaseIterable, Identifiable {
    case benefit   // чим більше, тим краще
    case cost      // чим менше, тим краще
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .benefit: return "Benefit"
        case .cost:    return "Cost"
        }
    }
}

struct Criterion: Identifiable {
    let id = UUID()
    let code: String      // C1, C2...
    let name: String      // назва критерію
    let type: CriterionType
    var weight: Double    // вага (може бути ненормована)
}

struct Alternative: Identifiable {
    let id = UUID()
    let name: String
    let values: [String: Double]  // code критерію -> значення
}

struct AlternativeScore: Identifiable {
    let id = UUID()
    let alternative: Alternative
    let score: Double
}

// MARK: - Обчислення SAW

/// Нормалізуємо ваги, щоб сума = 1
func normalizedWeights(from criteria: [Criterion]) -> [String: Double] {
    let sum = criteria.map { $0.weight }.reduce(0, +)
    guard sum > 0 else {
        // якщо всі ваги 0, повернемо рівномірні
        let equal = 1.0 / Double(max(criteria.count, 1))
        var dict: [String: Double] = [:]
        for c in criteria {
            dict[c.code] = equal
        }
        return dict
    }
    
    var dict: [String: Double] = [:]
    for c in criteria {
        dict[c.code] = c.weight / sum
    }
    return dict
}

/// Обчислюємо SAW-рейтинг для всіх альтернатив
func computeScores(alternatives: [Alternative], criteria: [Criterion]) -> [AlternativeScore] {
    if alternatives.isEmpty || criteria.isEmpty {
        return []
    }
    
    let weights = normalizedWeights(from: criteria)  // code -> w
    
    // Для кожного критерію знайдемо min/max значення серед альтернатив
    var minValues: [String: Double] = [:]
    var maxValues: [String: Double] = [:]
    
    for crit in criteria {
        let code = crit.code
        let vals = alternatives.compactMap { $0.values[code] }
        guard let minVal = vals.min(), let maxVal = vals.max() else {
            continue
        }
        minValues[code] = minVal
        maxValues[code] = maxVal
    }
    
    var results: [AlternativeScore] = []
    
    for alt in alternatives {
        var score = 0.0
        
        for crit in criteria {
            let code = crit.code
            guard let value = alt.values[code],
                  let minVal = minValues[code],
                  let maxVal = maxValues[code],
                  let w = weights[code] else { continue }
            
            let range = maxVal - minVal
            let normalized: Double
            
            if range == 0 {
                // всі значення однакові – нейтральна 0.5
                normalized = 0.5
            } else {
                switch crit.type {
                case .benefit:
                    normalized = (value - minVal) / range
                case .cost:
                    normalized = (maxVal - value) / range
                }
            }
            
            score += w * normalized
        }
        
        results.append(AlternativeScore(alternative: alt, score: score))
    }
    
    // сортуємо за спаданням рейтингу
    return results.sorted { $0.score > $1.score }
}

// MARK: - Основний екран

struct ContentView: View {
    @State private var criteria: [Criterion] = [
        Criterion(code: "C1", name: "Expected Profit (k$ / year)", type: .benefit, weight: 0.4),
        Criterion(code: "C2", name: "Project Duration (months)",   type: .cost,    weight: 0.2),
        Criterion(code: "C3", name: "Risk Level (1–10)",           type: .cost,    weight: 0.2),
        Criterion(code: "C4", name: "Strategic Importance (1–10)", type: .benefit, weight: 0.2)
    ]
    
    private let alternatives: [Alternative] = [
        Alternative(name: "Project A", values: ["C1": 120, "C2": 10, "C3": 6, "C4": 8]),
        Alternative(name: "Project B", values: ["C1": 90,  "C2": 7,  "C3": 4, "C4": 6]),
        Alternative(name: "Project C", values: ["C1": 150, "C2": 14, "C3": 8, "C4": 9]),
        Alternative(name: "Project D", values: ["C1": 80,  "C2": 6,  "C3": 3, "C4": 5])
    ]
    
    var scoredAlternatives: [AlternativeScore] {
        computeScores(alternatives: alternatives, criteria: criteria)
    }
    
    var bestAlternative: AlternativeScore? {
        scoredAlternatives.first
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Заголовок і короткий опис
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Multi-Criteria Decision Support")
                            .font(.title2.bold())
                        Text("SAW method – adjust criteria weights and see which project becomes the best.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Блок: краща альтернатива
                    if let best = bestAlternative {
                        BestAlternativeView(best: best)
                    }
                    
                    // Блок: ваги критеріїв
                    CriteriaWeightsView(criteria: $criteria)
                    
                    // Таблиця альтернатив
                    AlternativesListView(scoredAlternatives: scoredAlternatives)
                }
                .padding()
            }
            .navigationTitle("Decision Support")
        }
    }
}

// MARK: - Окремі підв’ю

struct BestAlternativeView: View {
    let best: AlternativeScore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Best Alternative")
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            Text(best.alternative.name)
                .font(.title3.bold())
            
            Text(String(format: "SAW score: %.3f", best.score))
                .font(.subheadline)
                .foregroundColor(.green)
            
            ProgressView(value: best.score, total: 1.0)
                .tint(.green)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(14)
    }
}

struct CriteriaWeightsView: View {
    @Binding var criteria: [Criterion]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Criteria Weights")
                    .font(.headline)
                Spacer()
                Text("Swipe sliders")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ForEach($criteria) { $criterion in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(criterion.code): \(criterion.name)")
                            .font(.subheadline.bold())
                        Spacer()
                        Text(criterion.type.displayName)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(criterion.type == .benefit ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
                            )
                    }
                    
                    HStack {
                        Slider(value: $criterion.weight, in: 0...1, step: 0.05)
                        Text(String(format: "%.2f", criterion.weight))
                            .font(.caption.monospacedDigit())
                            .frame(width: 44, alignment: .trailing)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(14)
    }
}

struct AlternativesListView: View {
    let scoredAlternatives: [AlternativeScore]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Alternatives Ranking")
                .font(.headline)
            
            ForEach(scoredAlternatives.indices, id: \.self) { index in
                let item = scoredAlternatives[index]
                AlternativeRowView(rank: index + 1, item: item)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(14)
    }
}

struct AlternativeRowView: View {
    let rank: Int
    let item: AlternativeScore
    
    var isBest: Bool { rank == 1 }
    
    var body: some View {
        HStack(spacing: 12) {
            Text("#\(rank)")
                .font(.headline)
                .frame(width: 32)
                .foregroundColor(isBest ? .green : .secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.alternative.name)
                    .font(.subheadline.bold())
                
                Text(String(format: "Score: %.3f", item.score))
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isBest {
                Text("Selected")
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.green.opacity(0.15))
                    )
                    .foregroundColor(.green)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isBest ? Color.green.opacity(0.06) : Color.clear)
        )
    }
}

// MARK: - Точка входу в застосунок

@main
struct DecisionSupportApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
