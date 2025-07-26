import SwiftUI

struct ReactionsDetailView: View {
    @Binding var isPresented: Bool
    let reactions: [Reaction]
    let onReactionAdded: (ReactionType) -> Void
    
    @State private var selectedReactionType: ReactionType?
    
    private var groupedReactions: [ReactionType: [Reaction]] {
        Dictionary(grouping: reactions, by: { $0.type })
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Close") {
                    isPresented = false
                }
                .font(.custom("VT323-Regular", size: 16))
                .foregroundColor(Colors.c0_500)
                
                Spacer()
                
                Text("Reactions")
                    .font(.custom("VT323-Regular", size: 18))
                    .foregroundColor(Colors.c0_050)
                
                Spacer()
                
                Button("Add") {
                    if let selectedType = selectedReactionType {
                        onReactionAdded(selectedType)
                        isPresented = false
                    }
                }
                .font(.custom("VT323-Regular", size: 16))
                .foregroundColor(selectedReactionType != nil ? Colors.c2_500 : Colors.c0_500)
                .disabled(selectedReactionType == nil)
            }
            .padding()
            .background(Color(red: 0.15, green: 0.1, blue: 0.1))
            
            ScrollView {
                VStack(spacing: 16) {
                    // Existing reactions grouped by type
                    ForEach(ReactionType.allCases, id: \.self) { reactionType in
                        if let reactionsForType = groupedReactions[reactionType] {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(reactionType.rawValue)
                                        .font(.system(size: 24))
                                    
                                    Text("\(reactionsForType.count)")
                                        .font(.custom("VT323-Regular", size: 16))
                                        .foregroundColor(Colors.c0_500)
                                    
                                    Spacer()
                                }
                                
                                // Users who reacted with this type
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                                    ForEach(reactionsForType) { reaction in
                                        HStack(spacing: 8) {
                                            Image(reaction.authorImage)
                                                .resizable()
                                                .frame(width: 24, height: 24)
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(Colors.c1_400, lineWidth: 1))
                                            
                                            Text(reaction.author)
                                                .font(.custom("VT323-Regular", size: 14))
                                                .foregroundColor(Colors.c0_050)
                                            
                                            Spacer()
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color(red: 0.20, green: 0.13, blue: 0.13))
                                        .cornerRadius(6)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(red: 0.18, green: 0.12, blue: 0.12))
                            .cornerRadius(8)
                        }
                    }
                    
                    // Add new reaction section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Add Reaction")
                            .font(.custom("VT323-Regular", size: 16))
                            .foregroundColor(Colors.c0_050)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                            ForEach(ReactionType.allCases, id: \.self) { reactionType in
                                Button(action: {
                                    selectedReactionType = reactionType
                                }) {
                                    VStack(spacing: 4) {
                                        Text(reactionType.rawValue)
                                            .font(.system(size: 32))
                                        
                                        Text(reactionType.displayName)
                                            .font(.custom("VT323-Regular", size: 12))
                                            .foregroundColor(Colors.c0_500)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(selectedReactionType == reactionType ? Colors.c2_500.opacity(0.3) : Color(red: 0.20, green: 0.13, blue: 0.13))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selectedReactionType == reactionType ? Colors.c2_500 : Color.clear, lineWidth: 2)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding()
                    .background(Color(red: 0.18, green: 0.12, blue: 0.12))
                    .cornerRadius(8)
                }
                .padding()
            }
            .background(Color(red: 0.13, green: 0.08, blue: 0.08))
        }
    }
}

#Preview {
    ReactionsDetailView(
        isPresented: .constant(true),
        reactions: [
            Reaction(author: "Will", authorImage: "will", type: .like, timestamp: Date()),
            Reaction(author: "Nic", authorImage: "nic", type: .fire, timestamp: Date()),
            Reaction(author: "Marek", authorImage: "marek", type: .muscle, timestamp: Date()),
            Reaction(author: "Chris", authorImage: "chris-h", type: .like, timestamp: Date()),
            Reaction(author: "Ziga", authorImage: "paul", type: .clap, timestamp: Date())
        ],
        onReactionAdded: { reactionType in
            print("Added reaction: \(reactionType)")
        }
    )
} 