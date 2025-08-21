import SwiftUI

// MARK: - Header View Component
struct WorkoutHeaderView: View {
    let message: Message
    
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
    
    var body: some View {
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
    }
    
    private func formatScore(_ value: Int) -> String {
        if value >= 1000 {
            let kValue = Double(value) / 1000.0
            return String(format: "%.1f", kValue).replacingOccurrences(of: ".0", with: "") + "k"
        }
        return "\(value)"
    }
}

// MARK: - Workout Score View Component
struct WorkoutScoreView: View {
    let workout: Workout
    
    private func getWorkoutIcon(for workoutType: WorkoutType) -> String {
        switch workoutType {
        case .strengthTraining:
            return "figure.strengthtraining.traditional"
        case .running:
            return "figure.run"
        case .walking:
            return "figure.walk"
        case .swimming:
            return "figure.pool.swim"
        case .hiking:
            return "figure.hiking"
        case .coreTraining:
            return "figure.core.training"
        case .yoga:
            return "figure.yoga"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 32) {
                Image(systemName: getWorkoutIcon(for: workout.type))
                    .font(.system(size: 48))
                    .foregroundColor(Colors.c0_050)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(workout.finalScore)")
                        .font(.custom("PressStart2P-Regular", size: 48))
                        .foregroundColor(Colors.c0_050)
                }
                
                Spacer()
                
                // Only show MANUAL badge
                if workout.mode == .manual {
                    Text("MANUAL")
                        .font(.custom("VT323-Regular", size: 14))
                        .foregroundColor(Colors.c0_050)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(red: 0.4, green: 0.26, blue: 0.26))
                        .cornerRadius(6)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Score Breakdown View Component
struct ScoreBreakdownView: View {
    let workout: Workout
    
    private func calculateItemEffect(_ item: Item, baseCalories: Int) -> Int {
        switch item.effect {
        case .multiplyNextWorkout(let multiplier):
            let newCalories = Int(Double(baseCalories) * multiplier)
            return newCalories - baseCalories
        case .deductPoints(let points):
            return -points
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            VStack(alignment: .leading, spacing: 4) {
                // Base Score Row
                HStack {
                    Text("Base Score")
                        .font(.custom("VT323-Regular", size: 20))
                        .foregroundColor(Colors.c0_050)
                    
                    Spacer()
                    
                    Text("\(workout.calories)")
                        .font(.custom("VT323-Regular", size: 20))
                        .foregroundColor(Colors.c0_050)
                }
                .padding(16)
                .background(Colors.c1_700)
                .frame(maxWidth: .infinity)
                
                // Items Effects Rows
                if !workout.items.isEmpty {
                    ForEach(workout.items) { workoutItem in
                        HStack {
                            Text("\(workoutItem.item.name) used by \(workoutItem.usedBy)")
                                .font(.custom("VT323-Regular", size: 20))
                                .foregroundColor(Colors.c0_050)
                            
                            Spacer()
                            
                            // Calculate and display item effect
                            let effectValue = calculateItemEffect(workoutItem.item, baseCalories: workout.calories)
                            Text(effectValue >= 0 ? "+\(effectValue)" : "\(effectValue)")
                                .font(.custom("VT323-Regular", size: 20))
                                .foregroundColor(effectValue >= 0 ? .green : .red)
                        }
                        .padding(16)
                        .background(Colors.c1_700)
                        .frame(maxWidth: .infinity)
                    }
                }
                
                // Final Score Row
                HStack {
                    Text("Final Score")
                        .font(.custom("VT323-Regular", size: 20))
                        .foregroundColor(Colors.c0_050)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text("\(workout.finalScore)")
                        .font(.custom("VT323-Regular", size: 20))
                        .foregroundColor(Colors.c0_050)
                        .fontWeight(.bold)
                }
                .padding(16)
                .background(Colors.c1_700)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Workout Data View Component
struct WorkoutDataView: View {
    let workout: Workout
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds) % 3600 / 60
        let secs = Int(seconds) % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%02d:%02d", minutes, secs)
        }
    }
    
    private func calculatePace(distance: Double, duration: TimeInterval) -> String {
        let paceSeconds = duration / distance
        let paceMinutes = Int(paceSeconds) / 60
        let paceSecs = Int(paceSeconds) % 60
        return "\(paceMinutes):\(String(format: "%02d", paceSecs)) /km"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(spacing: 24) {
                // Row 1: Distance and Duration
                HStack(spacing: 20) {
                    // Distance
                    if let distance = workout.distance {
                        VStack(spacing: 8) {
                            Text("DISTANCE")
                                .font(.custom("VT323-Regular", size: 18))
                                .foregroundColor(Colors.c0_050.opacity(0.8))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("\(String(format: "%.1f km", distance))")
                                .font(.custom("VT323-Regular", size: 30))
                                .foregroundColor(Colors.c0_050)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Duration
                    if workout.duration > 0 {
                        VStack(spacing: 8) {
                            Text("DURATION")
                                .font(.custom("VT323-Regular", size: 18))
                                .foregroundColor(Colors.c0_050.opacity(0.8))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(formatDuration(workout.duration))
                                .font(.custom("VT323-Regular", size: 30))
                                .foregroundColor(Colors.c0_050)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                // Row 2: Heart Rate and Calories
                HStack(spacing: 20) {
                    // Heart Rate
                    if let avgHR = workout.avgHeartRate, let maxHR = workout.maxHeartRate {
                        VStack(spacing: 8) {
                            Text("AVG HEART RATE")
                                .font(.custom("VT323-Regular", size: 18))
                                .foregroundColor(Colors.c0_050.opacity(0.8))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("\(avgHR) bpm")
                                .font(.custom("VT323-Regular", size: 30))
                                .foregroundColor(Colors.c0_050)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Calories
                    VStack(spacing: 8) {
                        Text("CALORIES")
                            .font(.custom("VT323-Regular", size: 18))
                            .foregroundColor(Colors.c0_050.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(workout.calories) cal")
                            .font(.custom("VT323-Regular", size: 30))
                            .foregroundColor(Colors.c0_050)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Row 3: Max Heart Rate and Pace (if distance and duration available)
                if let distance = workout.distance, workout.duration > 0 {
                    HStack(spacing: 20) {
                        // Max Heart Rate
                        if let maxHR = workout.maxHeartRate {
                            VStack(spacing: 8) {
                                Text("MAX HEART RATE")
                                    .font(.custom("VT323-Regular", size: 18))
                                    .foregroundColor(Colors.c0_050.opacity(0.8))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("\(maxHR) bpm")
                                    .font(.custom("VT323-Regular", size: 30))
                                    .foregroundColor(Colors.c0_050)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Pace
                        VStack(spacing: 8) {
                            Text("PACE")
                                .font(.custom("VT323-Regular", size: 18))
                                .foregroundColor(Colors.c0_050.opacity(0.8))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(calculatePace(distance: distance, duration: workout.duration))
                                .font(.custom("VT323-Regular", size: 30))
                                .foregroundColor(Colors.c0_050)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Photos View Component
struct PhotosView: View {
    let attachedImages: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PHOTOS")
                .font(.custom("VT323-Regular", size: 18))
                .foregroundColor(Colors.c0_500)
                .padding(.horizontal)
            
            if attachedImages.count == 1 {
                // Single image
                Image(attachedImages[0])
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
                    ForEach(Array(attachedImages.enumerated()), id: \.offset) { index, imageName in
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
}

// MARK: - Comments View Component
struct CommentsView: View {
    let comments: [Comment]
    let onCommentDetail: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("COMMENTS")
                    .font(.custom("VT323-Regular", size: 18))
                    .foregroundColor(Colors.c0_500)
                
                Spacer()
                
                Button(action: onCommentDetail) {
                    Text("\(comments.count)")
                        .font(.custom("VT323-Regular", size: 16))
                        .foregroundColor(Colors.c0_500)
                }
            }
            .padding(.horizontal)
            
            if !comments.isEmpty {
                VStack(spacing: 0) {
                    // Show "View all comments" if there are more than 10
                    if comments.count > 10 {
                        Button(action: onCommentDetail) {
                            Text("View all \(comments.count) comments")
                                .font(.custom("VT323-Regular", size: 14))
                                .foregroundColor(Colors.c0_500)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Show last 10 comments (most recent)
                    let lastComments = Array(comments.suffix(10))
                    ForEach(lastComments) { comment in
                        Button(action: onCommentDetail) {
                            CommentView(comment: comment)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if comment.id != lastComments.last?.id {
                            Divider()
                                .background(Colors.c0_500.opacity(0.3))
                                .padding(.horizontal, 12)
                        }
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
}

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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header with author info
                    WorkoutHeaderView(message: message)
                    
                    // Workout Icon and Score Section
                    if let workout = message.workout {
                        WorkoutScoreView(workout: workout)
                    }
                    
                    // Score Breakdown Section
                    if let workout = message.workout {
                        ScoreBreakdownView(workout: workout)
                    }
                    
                    // Workout Data Section
                    if let workout = message.workout {
                        WorkoutDataView(workout: workout)
                    }
                    
                    // Workout Comparison Section
                    if let workout = message.workout {
                        WorkoutComparisonView(
                            currentWorkout: workout,
                            currentAuthor: message.author
                        )
                    }
                    
                    // Photos section
                    if !message.attachedImages.isEmpty {
                        PhotosView(attachedImages: message.attachedImages)
                    }
                    
                    // Reactions section
                    ReactionsView(
                        reactions: currentMessage.reactions,
                        commentCount: currentMessage.comments.count,
                        onReactionTapped: { reactionType in
                            addReaction(reactionType)
                        },
                        onReactionLongPressed: {
                            showReactionsDetail = true
                        },
                        onCommentsTapped: {
                            showCommentsDetail = true
                        },
                        onAddReactionTapped: {
                            showReactionsDetail = true
                        }
                    )
                    
                    // Comments section
                    CommentsView(
                        comments: currentMessage.comments,
                        onCommentDetail: { showCommentsDetail = true }
                    )
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
                type: .running,
                value: 1100,
                calories: 1100,
                mode: .manual,
                distance: 10.5,
                duration: 52 * 60,
                avgHeartRate: 165,
                maxHeartRate: 185
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