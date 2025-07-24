import SwiftUI

struct SocialPostView: View {
    let message: Message
    
    private var isJumboEmoji: Bool {
        if let content = message.content {
            let scalarString = content.unicodeScalars
            return scalarString.allSatisfy { scalar in
                scalar.properties.isEmoji && !scalar.properties.isWhitespace
            }
        }
        return false
    }
    
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
    
    private var authorNameColor: Color {
        guard let score = message.score, let rankInt = Int(score.rank) else { return Colors.c2_500 }
        switch rankInt {
        case 1: return Color(red: 0.93, green: 0.76, blue: 0.33) // Gold
        case 2: return Color(red: 0.82, green: 0.73, blue: 0.62) // Beige
        case 3: return Color(red: 0.82, green: 0.45, blue: 0.33) // Copper
        default: return Colors.c0_500
        }
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    private func getLocation() -> String {
        return message.location ?? "Gym"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Post header
            HStack(alignment: .center, spacing: 12) {
                // Avatar
                Image(message.authorImage)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Colors.c1_400, lineWidth: 2))
                
                // Name and rank/score
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(message.author)
                            .foregroundColor(authorNameColor)
                            .font(.custom("VT323-Regular", size: 18))
                        
                        if let score = message.score {
                            HStack(spacing: 0) {
                                Text(score.rank)
                                    .font(.custom("VT323-Regular", size: 14))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 1)
                                    .background(rankColor(score.rank))
                                    .foregroundColor(["1", "2", "3"].contains(score.rank) ? Colors.c1_400 : Colors.c0_050)
                                Text("\(formatScore(score.score))")
                                    .font(.custom("VT323-Regular", size: 14))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 1)
                                    .background(
                                        ZStack {
                                            Color.clear
                                            Rectangle()
                                                .strokeBorder(rankColor(score.rank), lineWidth: 1)
                                        }
                                    )
                                    .foregroundColor(Colors.c0_050)
                            }
                        }
                    }
                    
                    // Timestamp and location
                    HStack(spacing: 8) {
                        Text(formatTimestamp(message.timestamp))
                            .font(.custom("VT323-Regular", size: 14))
                            .foregroundColor(Colors.c0_500)
                        
                        Text("•")
                            .font(.custom("VT323-Regular", size: 14))
                            .foregroundColor(Colors.c0_500)
                        
                        Text(getLocation())
                            .font(.custom("VT323-Regular", size: 14))
                            .foregroundColor(Colors.c0_500)
                    }
                }
                
                Spacer()
            }
            
            // Post content
            VStack(alignment: .leading, spacing: 8) {
                if let content = message.content {
                    if isJumboEmoji {
                        Text(content)
                            .font(.system(size: 48))
                    } else {
                        Text(content)
                            .font(.custom("VT323-Regular", size: 18))
                            .foregroundColor(Colors.c0_050)
                            .padding()
                            .background(Colors.c1_400.opacity(0.3))
                    }
                }
                
                if let workout = message.workout {
                    let card = HStack(alignment: .center, spacing: 20) {
                        HStack(alignment: .center) {
                            Image(systemName: workout.type.icon)
                                .font(.system(size: 24))
                            Text(formatWorkoutValue(workout.value))
                                .font(.custom("PressStart2P-Regular", size: getWorkoutValueFontSize(workout.value)))
                        }
                        VStack(alignment: .trailing) {
                            Text("\(formatWorkoutValue(workout.calories)) Cal")
                                .font(.custom("VT323-Regular", size: 16))
                        }
                    }
                    .foregroundColor(Colors.c0_050)
                    .padding()
                    .background(Colors.c1_400)
                    .fixedSize(horizontal: true, vertical: false)
                    .overlay(
                        Group {
                            if workout.mode == .manual {
                                Text("MANUAL")
                                    .font(.custom("VT323-Regular", size: 14))
                                    .foregroundColor(Colors.c0_500)
                                    .padding(.vertical, 1)
                                    .padding(.horizontal, 4)
                                    .background(Color(red: 0.3, green: 0.2, blue: 0.1))
                                    .cornerRadius(0)
                            }
                        }, alignment: .bottomTrailing
                    )
                    card
                }
            }
        }
        .padding()
        .background(Color(red: 0.15, green: 0.1, blue: 0.1))
        .cornerRadius(8)
    }
    
    private func formatWorkoutValue(_ value: Int) -> String {
        if value >= 1000 {
            let kValue = Double(value) / 1000.0
            return String(format: "%.1fk", kValue)
                }
        return "\(value)"
    }
    
    private func getWorkoutValueFontSize(_ value: Int) -> CGFloat {
        if value < 400 {
            return 18
        } else if value >= 1000 {
            return 28
        }
        return 24
    }
    
    private func formatScore(_ value: Int) -> String {
        if value >= 1000 {
            let kValue = Double(value) / 1000.0
            return String(format: "%.1f", kValue).replacingOccurrences(of: ".0", with: "") + "k"
        }
        return "\(value)"
    }
}

#Preview {
    SocialPostView(message: Message(
        author: "Will Corbett",
        authorImage: "will",
        content: "Let's crush it! 💪",
        workout: Workout(
            type: .strengthTraining,
            value: 160,
            calories: 160,
            mode: .auto
        ),
        timestamp: Date(),
        score: (rank: "1", score: 2458),
        location: "Gym"
    ))
    .padding()
    .background(Color(red: 0.13, green: 0.08, blue: 0.08))
} 