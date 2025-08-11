import SwiftUI

struct ReactionsView: View {
    let reactions: [Reaction]
    let commentCount: Int
    let onReactionTapped: (ReactionType) -> Void
    let onReactionLongPressed: () -> Void
    let onCommentsTapped: () -> Void
    let onAddReactionTapped: () -> Void
    
    private var groupedReactions: [ReactionType: Int] {
        Dictionary(grouping: reactions, by: { $0.type })
            .mapValues { $0.count }
    }
    
    private var sortedReactionTypes: [ReactionType] {
        // Use a fixed order to prevent swapping
        let fixedOrder: [ReactionType] = [.like, .fire, .muscle, .clap, .rocket, .crown]
        return fixedOrder.filter { groupedReactions.keys.contains($0) }
    }
    
    private func hasCurrentPlayerReaction(_ reactionType: ReactionType) -> Bool {
        reactions.contains { reaction in
            reaction.type == reactionType && reaction.author == "Will Corbett"
        }
    }
    
    private func getCurrentPlayerReactionCount(_ reactionType: ReactionType) -> Int {
        reactions.filter { reaction in
            reaction.type == reactionType && reaction.author == "Will Corbett"
        }.count
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // Reactions
            HStack(spacing: 8) {
                // Show existing reactions if any
                if !reactions.isEmpty {
                    ForEach(sortedReactionTypes.prefix(4), id: \.self) { reactionType in
                        Button(action: {
                            // Tapping on a reaction adds another one of the same type
                            onReactionTapped(reactionType)
                        }) {
                            HStack(spacing: 2) {
                                Text(reactionType.rawValue)
                                    .font(.system(size: 16))
                                
                                // Always show count, even if it's 1
                                let totalCount = groupedReactions[reactionType] ?? 0
                                let userCount = getCurrentPlayerReactionCount(reactionType)
                                
                                if totalCount > 0 {
                                    Text("\(totalCount)")
                                        .font(.custom("VT323-Regular", size: 12))
                                        .foregroundColor(userCount > 0 ? Colors.c2_500 : Colors.c0_050)
                                }
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                hasCurrentPlayerReaction(reactionType) 
                                    ? Colors.c2_500.opacity(0.3) 
                                    : Color(red: 0.2, green: 0.13, blue: 0.13)
                            )
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        hasCurrentPlayerReaction(reactionType) ? Colors.c2_500 : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    if reactions.count > 4 {
                        Text("+\(reactions.count - 4)")
                            .font(.custom("VT323-Regular", size: 12))
                            .foregroundColor(Colors.c0_500)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(red: 0.2, green: 0.13, blue: 0.13))
                            .cornerRadius(12)
                    }
                }
                
                // Add reaction button (always visible)
                Button(action: {
                    onAddReactionTapped()
                }) {
                    Image(systemName: "heart")
                        .font(.system(size: 14))
                        .foregroundColor(Colors.c0_500)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(red: 0.2, green: 0.13, blue: 0.13))
                        .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .onLongPressGesture {
                onReactionLongPressed()
            }
            
            Spacer()
            
            // Comments button (always visible)
            Button(action: {
                onCommentsTapped()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "bubble.left")
                        .font(.system(size: 14))
                        .foregroundColor(Colors.c0_500)
                    
                    // Only show comment count if there are comments
                    if commentCount > 0 {
                        Text("\(commentCount)")
                            .font(.custom("VT323-Regular", size: 14))
                            .foregroundColor(Colors.c0_500)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(red: 0.2, green: 0.13, blue: 0.13))
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

#Preview {
    ReactionsView(
        reactions: [
            Reaction(author: "Will", authorImage: "will", type: .like, timestamp: Date()),
            Reaction(author: "Nic", authorImage: "nic", type: .fire, timestamp: Date()),
            Reaction(author: "Marek", authorImage: "marek", type: .muscle, timestamp: Date()),
            Reaction(author: "Chris", authorImage: "chris-h", type: .like, timestamp: Date()),
            Reaction(author: "Ziga", authorImage: "paul", type: .clap, timestamp: Date())
        ],
        commentCount: 5,
        onReactionTapped: { reactionType in
            print("Tapped reaction: \(reactionType)")
        },
        onReactionLongPressed: {
            print("Long pressed reactions")
        },
        onCommentsTapped: {
            print("Tapped comments")
        },
        onAddReactionTapped: {
            print("Tapped add reaction")
        }
    )
    .padding()
    .background(Color(red: 0.13, green: 0.08, blue: 0.08))
} 