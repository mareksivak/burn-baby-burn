import SwiftUI

struct SocialPostView: View {
    let message: Message
    let onCommentPosted: (String) -> Void
    let onReactionAdded: (ReactionType) -> Void
    
    @State private var showCommentsDetail: Bool = false
    
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
                
                // Attached image
                if let attachedImage = message.attachedImage {
                    Image(attachedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Colors.c1_400.opacity(0.3), lineWidth: 1)
                        )
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
            
            // Reactions and comments
            ReactionsView(
                reactions: message.reactions,
                commentCount: message.comments.count,
                onReactionTapped: { reactionType in
                    onReactionAdded(reactionType)
                },
                onReactionLongPressed: {
                    // Show reactions detail
                },
                onCommentsTapped: {
                    showCommentsDetail = true
                }
            )
            .padding(.top, 4)
            
            // Comment previews (show by default if there are comments)
            if !message.comments.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(message.comments.prefix(2))) { comment in
                        CommentView(comment: comment)
                        
                        if comment.id != message.comments.prefix(2).last?.id {
                            Divider()
                                .background(Colors.c0_500.opacity(0.3))
                                .padding(.horizontal, 12)
                        }
                    }
                    
                    // Show "View all comments" if there are more than 2
                    if message.comments.count > 2 {
                        Button(action: {
                            showCommentsDetail = true
                        }) {
                            Text("View all \(message.comments.count) comments")
                                .font(.custom("VT323-Regular", size: 14))
                                .foregroundColor(Colors.c0_500)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(red: 0.15, green: 0.1, blue: 0.1))
        .cornerRadius(8)
        .sheet(isPresented: $showCommentsDetail) {
            CommentsDetailView(
                isPresented: $showCommentsDetail,
                comments: message.comments,
                onCommentPosted: onCommentPosted
            )
        }
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
    SocialPostView(
        message: Message(
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
            location: "Gym",
            attachedImage: "workout",
            comments: [
                Comment(author: "Nic", authorImage: "nic", content: "Great work! 💪", timestamp: Date()),
                Comment(author: "Marek", authorImage: "marek", content: "Keep it up! 🔥", timestamp: Date()),
                Comment(author: "Chris", authorImage: "chris-h", content: "Amazing progress! 👏", timestamp: Date())
            ],
            reactions: [
                Reaction(author: "Nic", authorImage: "nic", type: .like, timestamp: Date()),
                Reaction(author: "Marek", authorImage: "marek", type: .fire, timestamp: Date()),
                Reaction(author: "Chris", authorImage: "chris-h", type: .muscle, timestamp: Date())
            ]
        ),
        onCommentPosted: { comment in
            print("Posted comment: \(comment)")
        },
        onReactionAdded: { reactionType in
            print("Added reaction: \(reactionType)")
        }
    )
    .padding()
    .background(Color(red: 0.13, green: 0.08, blue: 0.08))
} 