import SwiftUI

struct ReactionsView: View {
    let reactions: [Reaction]
    let commentCount: Int
    let onReactionTapped: (ReactionType) -> Void
    let onReactionLongPressed: () -> Void
    let onCommentsTapped: () -> Void
    
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
    
    var body: some View {
        if !reactions.isEmpty || commentCount > 0 {
            HStack(spacing: 8) {
                // Reactions
                if !reactions.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(sortedReactionTypes.prefix(4), id: \.self) { reactionType in
                            Button(action: {
                                onReactionTapped(reactionType)
                            }) {
                                HStack(spacing: 2) {
                                    Text(reactionType.rawValue)
                                        .font(.system(size: 16))
                                    
                                    if let count = groupedReactions[reactionType], count > 1 {
                                        Text("\(count)")
                                            .font(.custom("VT323-Regular", size: 12))
                                            .foregroundColor(Colors.c0_050)
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
                    .onLongPressGesture {
                        onReactionLongPressed()
                    }
                }
                
                Spacer()
                
                // Comments
                if commentCount > 0 {
                    Button(action: {
                        onCommentsTapped()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "bubble.left")
                                .font(.system(size: 14))
                                .foregroundColor(Colors.c0_500)
                            
                            Text("\(commentCount)")
                                .font(.custom("VT323-Regular", size: 14))
                                .foregroundColor(Colors.c0_500)
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
        }
    )
    .padding()
    .background(Color(red: 0.13, green: 0.08, blue: 0.08))
} 