import SwiftUI

struct WorkoutDetailView: View {
    let message: Message
    @Binding var isPresented: Bool
    let onCommentPosted: (String) -> Void
    let onReactionAdded: (ReactionType) -> Void
    
    @State private var showCommentsDetail: Bool = false
    @State private var showReactionsDetail: Bool = false
    @State private var currentMessage: Message // Local mutable copy
    
    init(message: Message, isPresented: Binding<Bool>, onCommentPosted: @escaping (String) -> Void, onReactionAdded: @escaping (ReactionType) -> Void) {
        self.message = message
        self._isPresented = isPresented
        self.onCommentPosted = onCommentPosted
        self.onReactionAdded = onReactionAdded
        self._currentMessage = State(initialValue: message)
    }
    
    private func addReaction(_ reactionType: ReactionType) {
        let newReaction = Reaction(
            author: "Will Corbett", // Current user
            authorImage: "will", // Current user's image
            type: reactionType,
            timestamp: Date()
        )
        currentMessage.reactions.append(newReaction)
        onReactionAdded(reactionType)
    }
    
    private func addComment(_ content: String) {
        let newComment = Comment(
            author: "Will Corbett", // Current user
            authorImage: "will", // Current user's image
            content: content,
            timestamp: Date()
        )
        currentMessage.comments.append(newComment)
        onCommentPosted(content)
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
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d 'at' h:mm a"
        return formatter.string(from: date)
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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header with author info
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .center, spacing: 16) {
                            Image(message.authorImage)
                                .resizable()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Colors.c1_400, lineWidth: 3))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 12) {
                                    Text(message.author)
                                        .foregroundColor(authorNameColor)
                                        .font(.custom("VT323-Regular", size: 24))
                                    
                                    if let score = message.score {
                                        HStack(spacing: 0) {
                                            Text(score.rank)
                                                .font(.custom("VT323-Regular", size: 16))
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 2)
                                                .background(rankColor(score.rank))
                                                .foregroundColor(["1", "2", "3"].contains(score.rank) ? Colors.c1_400 : Colors.c0_050)
                                            Text("\(formatScore(score.score))")
                                                .font(.custom("VT323-Regular", size: 16))
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 2)
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
                                
                                Text(formatTimestamp(message.timestamp))
                                    .font(.custom("VT323-Regular", size: 16))
                                    .foregroundColor(Colors.c0_500)
                                
                                if let location = message.location {
                                    HStack(spacing: 8) {
                                        Image(systemName: "location.fill")
                                            .foregroundColor(Colors.c0_500)
                                        Text(location)
                                            .font(.custom("VT323-Regular", size: 16))
                                            .foregroundColor(Colors.c0_500)
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                        
                        // Text content if any
                        if let content = message.content {
                            Text(content)
                                .font(.custom("VT323-Regular", size: 18))
                                .foregroundColor(Colors.c0_050)
                                .padding()
                                .background(Colors.c1_400.opacity(0.3))
                                .cornerRadius(8)
                        }
                    }
                    
                    // Workout card (enhanced)
                    if let workout = message.workout {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("WORKOUT DETAILS")
                                .font(.custom("VT323-Regular", size: 18))
                                .foregroundColor(Colors.c0_500)
                                .padding(.horizontal)
                            
                            VStack(spacing: 20) {
                                // Workout type and value
                                HStack(alignment: .center, spacing: 24) {
                                    VStack(spacing: 8) {
                                        Image(systemName: workout.type.icon)
                                            .font(.system(size: 32))
                                            .foregroundColor(Colors.c2_500)
                                        Text(workout.type.rawValue)
                                            .font(.custom("VT323-Regular", size: 16))
                                            .foregroundColor(Colors.c0_500)
                                            .multilineTextAlignment(.center)
                                    }
                                    
                                    VStack(spacing: 4) {
                                        Text(formatWorkoutValue(workout.finalScore))
                                            .font(.custom("PressStart2P-Regular", size: getWorkoutValueFontSize(workout.finalScore)))
                                            .foregroundColor(Colors.c0_050)
                                        Text("POINTS")
                                            .font(.custom("VT323-Regular", size: 12))
                                            .foregroundColor(Colors.c0_500)
                                    }
                                    
                                    VStack(spacing: 4) {
                                        Text("\(formatWorkoutValue(workout.calories))")
                                            .font(.custom("PressStart2P-Regular", size: 24))
                                            .foregroundColor(Colors.c0_050)
                                        Text("CALORIES")
                                            .font(.custom("VT323-Regular", size: 12))
                                            .foregroundColor(Colors.c0_500)
                                    }
                                }
                                .padding()
                                .background(Colors.c1_400)
                                .cornerRadius(8)
                                
                                // Items section
                                if !workout.items.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("ITEMS USED")
                                            .font(.custom("VT323-Regular", size: 16))
                                            .foregroundColor(Colors.c0_500)
                                            .padding(.horizontal)
                                        
                                        VStack(spacing: 8) {
                                            ForEach(workout.items) { workoutItem in
                                                HStack(spacing: 12) {
                                                    Image(workoutItem.item.imageName)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 32, height: 32)
                                                    
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(workoutItem.item.name)
                                                            .font(.custom("VT323-Regular", size: 14))
                                                            .foregroundColor(Colors.c0_050)
                                                        Text("Used by \(workoutItem.usedBy)")
                                                            .font(.custom("VT323-Regular", size: 12))
                                                            .foregroundColor(Colors.c0_500)
                                                    }
                                                    
                                                    Spacer()
                                                    
                                                    Text(workoutItem.item.description)
                                                        .font(.custom("VT323-Regular", size: 12))
                                                        .foregroundColor(Colors.c0_500)
                                                        .multilineTextAlignment(.trailing)
                                                }
                                                .padding()
                                                .background(Colors.c1_400.opacity(0.3))
                                                .cornerRadius(8)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                
                                // Workout mode indicator
                                if workout.mode == .manual {
                                    HStack {
                                        Image(systemName: "hand.raised.fill")
                                            .foregroundColor(Colors.c0_500)
                                        Text("MANUAL ENTRY")
                                            .font(.custom("VT323-Regular", size: 14))
                                            .foregroundColor(Colors.c0_500)
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                    
                    // Photos section
                    if !message.attachedImages.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("PHOTOS")
                                .font(.custom("VT323-Regular", size: 18))
                                .foregroundColor(Colors.c0_500)
                                .padding(.horizontal)
                            
                            if message.attachedImages.count == 1 {
                                // Single image
                                Image(message.attachedImages[0])
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 300)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Colors.c1_400.opacity(0.3), lineWidth: 1)
                                    )
                                    .padding(.horizontal)
                            } else {
                                // Multiple images in a grid
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                                    ForEach(Array(message.attachedImages.enumerated()), id: \.offset) { index, imageName in
                                        Image(imageName)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(height: 150)
                                            .clipped()
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Colors.c1_400.opacity(0.3), lineWidth: 1)
                                            )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Reactions section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("REACTIONS")
                                .font(.custom("VT323-Regular", size: 18))
                                .foregroundColor(Colors.c0_500)
                            
                            Spacer()
                            
                            Button(action: {
                                showReactionsDetail = true
                            }) {
                                Text("\(currentMessage.reactions.count)")
                                    .font(.custom("VT323-Regular", size: 16))
                                    .foregroundColor(Colors.c0_500)
                            }
                        }
                        .padding(.horizontal)
                        
                        if !currentMessage.reactions.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(currentMessage.reactions) { reaction in
                                        VStack(spacing: 4) {
                                            Image(reaction.authorImage)
                                                .resizable()
                                                .frame(width: 40, height: 40)
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(Colors.c1_400, lineWidth: 2))
                                            
                                            Text(reaction.type.rawValue)
                                                .font(.system(size: 20))
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        } else {
                            Text("No reactions yet")
                                .font(.custom("VT323-Regular", size: 16))
                                .foregroundColor(Colors.c0_500)
                                .padding(.horizontal)
                        }
                    }
                    
                    // Comments section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("COMMENTS")
                                .font(.custom("VT323-Regular", size: 18))
                                .foregroundColor(Colors.c0_500)
                            
                            Spacer()
                            
                            Button(action: {
                                showCommentsDetail = true
                            }) {
                                Text("\(currentMessage.comments.count)")
                                    .font(.custom("VT323-Regular", size: 16))
                                    .foregroundColor(Colors.c0_500)
                            }
                        }
                        .padding(.horizontal)
                        
                        if !currentMessage.comments.isEmpty {
                            VStack(spacing: 0) {
                                // Show last 3 comments (most recent)
                                let lastComments = Array(currentMessage.comments.suffix(3))
                                ForEach(lastComments) { comment in
                                    CommentView(comment: comment)
                                    
                                    if comment.id != lastComments.last?.id {
                                        Divider()
                                            .background(Colors.c0_500.opacity(0.3))
                                            .padding(.horizontal, 12)
                                    }
                                }
                                
                                if currentMessage.comments.count > 3 {
                                    Button(action: {
                                        showCommentsDetail = true
                                    }) {
                                        Text("View all \(currentMessage.comments.count) comments")
                                            .font(.custom("VT323-Regular", size: 14))
                                            .foregroundColor(Colors.c0_500)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        } else {
                            Text("No comments yet")
                                .font(.custom("VT323-Regular", size: 16))
                                .foregroundColor(Colors.c0_500)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(red: 0.13, green: 0.08, blue: 0.08))
            .navigationTitle("Workout Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        isPresented = false
                    }
                    .foregroundColor(Colors.c0_050)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Add reaction functionality
                        showReactionsDetail = true
                    }) {
                        Image(systemName: "heart")
                            .foregroundColor(Colors.c0_050)
                    }
                }
            }
        }
        .sheet(isPresented: $showCommentsDetail) {
            CommentsDetailView(
                isPresented: $showCommentsDetail,
                comments: currentMessage.comments,
                onCommentPosted: { comment in
                    addComment(comment)
                }
            )
        }
        .sheet(isPresented: $showReactionsDetail) {
            ReactionsDetailView(
                isPresented: $showReactionsDetail,
                reactions: currentMessage.reactions,
                onReactionAdded: { reactionType in
                    addReaction(reactionType)
                }
            )
        }
    }
}

#Preview {
    WorkoutDetailView(
        message: Message(
            author: "Will Corbett",
            authorImage: "will",
            content: "Just crushed my workout! 💪 Feeling amazing after this session.",
            workout: Workout(
                type: .strengthTraining,
                value: 160,
                calories: 160,
                mode: .auto
            ),
            timestamp: Date(),
            score: (rank: "1", score: 2458),
            location: "Gold's Gym",
            attachedImages: ["photo1", "photo3", "photo5"],
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
        isPresented: .constant(true),
        onCommentPosted: { comment in
            print("Posted comment: \(comment)")
        },
        onReactionAdded: { reactionType in
            print("Added reaction: \(reactionType)")
        }
    )
} 