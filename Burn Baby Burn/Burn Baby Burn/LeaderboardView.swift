import SwiftUI

struct LeaderboardView: View {
    @Environment(\.dismiss) private var dismiss
    let messages: [Message]
    
    private var sortedUsers: [(name: String, image: String, score: Int, rank: String)] {
        let userScoresDict: [String: (name: String, image: String, score: Int, rank: String)] = messages
            .compactMap { message -> (name: String, image: String, score: Int, rank: String)? in
                guard let score = message.score else { return nil }
                return (message.author, message.authorImage, score.score, score.rank)
            }
            .reduce(into: [String: (name: String, image: String, score: Int, rank: String)]()) { result, user in
                if let existing = result[user.name] {
                    if user.score > existing.score {
                        result[user.name] = user
                    }
                } else {
                    result[user.name] = user
                }
            }
        let userScores = Array(userScoresDict.values)
            .sorted { (lhs, rhs) in lhs.score > rhs.score }
        return userScores.enumerated().map { index, user in
            (user.name, user.image, user.score, "\(index + 1)")
        }
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.13, green: 0.08, blue: 0.08)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Colors.c0_050)
                    }
                    .padding(.leading, 12)
                    
                    Text("Leaderboard")
                        .font(.custom("VT323-Regular", size: 20))
                        .foregroundColor(Colors.c0_050)
                    
                    Spacer()
                }
                .padding(.vertical, 8)
                .background(Color(red: 0.15, green: 0.1, blue: 0.1))
                
                // Leaderboard content
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(sortedUsers, id: \.name) { user in
                            LeaderboardRow(
                                rank: user.rank,
                                name: user.name,
                                image: user.image,
                                score: user.score
                            )
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct LeaderboardRow: View {
    let rank: String
    let name: String
    let image: String
    let score: Int
    
    private func rankColor(_ rank: String) -> Color {
        if let rankInt = Int(rank) {
            switch rankInt {
            case 1: return Color(red: 0.93, green: 0.76, blue: 0.33) // Gold
            case 2: return Color(red: 0.82, green: 0.73, blue: 0.62) // Beige
            case 3: return Color(red: 0.82, green: 0.45, blue: 0.33) // Copper
            default: return Color(red: 0.3, green: 0.2, blue: 0.1)
            }
        }
        return Color(red: 0.3, green: 0.2, blue: 0.1)
    }
    
    private func formatScore(_ value: Int) -> String {
        if value >= 1000 {
            let kValue = Double(value) / 1000.0
            return String(format: "%.1f", kValue).replacingOccurrences(of: ".0", with: "") + "k"
        }
        return "\(value)"
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text(rank)
                .font(.custom("VT323-Regular", size: 24))
                .frame(width: 40)
                .padding(.vertical, 8)
                .background(rankColor(rank))
                .foregroundColor(["1", "2", "3"].contains(rank) ? Colors.c1_400 : Colors.c0_050)
            
            // Profile image
            Image(image)
                .resizable()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(Circle().stroke(Colors.c1_400, lineWidth: 2))
            
            // Name
            Text(name)
                .font(.custom("VT323-Regular", size: 20))
                .foregroundColor(Colors.c0_050)
            
            Spacer()
            
            // Score
            Text(formatScore(score))
                .font(.custom("VT323-Regular", size: 20))
                .foregroundColor(Colors.c0_050)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    ZStack {
                        Color(red: 0.13, green: 0.08, blue: 0.08)
                        Rectangle()
                            .strokeBorder(rankColor(rank), lineWidth: 2)
                    }
                )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(red: 0.15, green: 0.1, blue: 0.1))
    }
}

#Preview {
    LeaderboardView(messages: AppConfig.generateMessages())
} 