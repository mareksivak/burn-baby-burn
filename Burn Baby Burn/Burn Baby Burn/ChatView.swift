import SwiftUI

struct ChatView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var remainingTime: TimeInterval
    @State private var messages: [Message] = AppConfig.generateMessages()
    @State private var scrollProxy: ScrollViewProxy? = nil
    @State private var showLeaderboard: Bool = false
    @State private var showItemModal: Bool = false
    @State private var playersForItems: [Player] = []
    
    private var safeAreaInset: CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
    }
    
    // Sort messages by timestamp, most recent first
    private var sortedMessages: [Message] {
        messages.sorted { $0.timestamp > $1.timestamp }
    }
    
    init() {
        let days: TimeInterval = 2 * 24 * 3600  // 2 days
        let hours: TimeInterval = 10 * 3600     // 10 hours
        let minutes: TimeInterval = 5 * 60      // 5 minutes
        let seconds: TimeInterval = 30          // 30 seconds
        _remainingTime = State(initialValue: days + hours + minutes + seconds)
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.13, green: 0.08, blue: 0.08)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                VStack(spacing: 0) {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image("back")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundColor(Colors.c0_050)
                        }
                        .padding(.leading, 12)  // Changed from 20 to 12
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Calorie Crushers")
                                .font(.custom("VT323-Regular", size: 20))
                                .foregroundColor(Colors.c0_050)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            Text(formatTimeRemaining(remainingTime))
                                .font(.custom("VT323-Regular", size: 16))
                                .foregroundColor(Colors.c0_500)
                        }
                        .onTapGesture {
                            showLeaderboard = true
                        }
                        
                        Spacer()
                        
                        // Steps and rank/score indicator for Will Corbett
                        if let stepsWorkout = messages.reversed().compactMap({ ($0.author == "Will Corbett" && $0.workout?.type == .walking) ? $0.workout : nil }).first,
                           let myScore = messages.reversed().compactMap({ $0.author == "Will Corbett" ? $0.score : nil }).first(where: { $0.rank != "-" && $0.score != 0 }) {
                            HStack(spacing: 4) {
                                // Steps box
                                VStack(spacing: 0) {
                                    Image("steps")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 24)
                                    Text(formatScore(stepsWorkout.value))
                                        .font(.custom("VT323-Regular", size: 18))
                                        .frame(width: 44)
                                        .padding(.vertical, 2)
                                        .foregroundColor(Colors.c0_050)
                                }
                                .frame(width: 44)
                                .background(Color(red: 0.41, green: 0.25, blue: 0.20)) // #693F32
                                .cornerRadius(0)
                                // Rank/score box
                                VStack(spacing: 0) {
                                    Text(myScore.rank)
                                        .font(.custom("VT323-Regular", size: 18))
                                        .frame(width: 44)
                                        .padding(.vertical, 2)
                                        .background(rankColor(myScore.rank))
                                        .foregroundColor(["1", "2", "3"].contains(myScore.rank) ? Colors.c1_400 : Colors.c0_050)
                                    Text(formatScore(myScore.score))
                                        .font(.custom("VT323-Regular", size: 18))
                                        .frame(width: 44)
                                        .padding(.vertical, 2)
                                        .background(
                                            ZStack {
                                                Color(red: 0.13, green: 0.08, blue: 0.08)
                                                Rectangle()
                                                    .strokeBorder(rankColor(myScore.rank), lineWidth: 2)
                                            }
                                        )
                                        .foregroundColor(Colors.c0_050)
                                }
                            }
                            .padding(.trailing, 12)  // Changed from 20 to 12
                        }
                    }
                }
                .padding(.vertical, 8)
                .background(Color(red: 0.15, green: 0.1, blue: 0.1))
                
                ZStack {
                    // Social feed posts
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 16) {
                                ForEach(sortedMessages) { message in
                                    SocialPostView(
                                        message: message,
                                        onCommentPosted: { comment in
                                            // Static mode - comments are not added dynamically
                                            print("Comment posted (static mode): \(comment)")
                                        },
                                        onReactionAdded: { reactionType in
                                            // Static mode - reactions are not added dynamically
                                            print("Reaction added (static mode): \(reactionType)")
                                        }
                                    )
                                    .id(message.id)
                                }
                            }
                            .padding()
                        }
                        .onAppear {
                            scrollProxy = proxy
                            // Start at the top (most recent posts)
                            if let firstMessage = sortedMessages.first {
                                scrollProxy?.scrollTo(firstMessage.id, anchor: .top)
                            }
                        }

                    }
                    
                    // Floating item button
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                showItemModal = true
                            }) {
                                Image("item-omnomnom")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 44, height: 44)
                                    .background(Color(red: 0.20, green: 0.13, blue: 0.13))
                                    .cornerRadius(0) // Sharp edges
                            }
                            .padding(.trailing, 16)
                        }
                        .padding(.top, 8)
                        Spacer()
                    }
                }
                

            }
        }
        .overlay {
            if showLeaderboard {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showLeaderboard = false
                        }
                    }
            }
        }
        .overlay(alignment: .trailing) {
            if showLeaderboard {
                LeaderboardView(messages: messages)
                    .transition(.move(edge: .trailing))
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0.13, green: 0.08, blue: 0.08))
            }
        }
        .sheet(isPresented: $showItemModal) {
            ItemFlowView(isPresented: $showItemModal, players: $playersForItems)
        }
        .animation(.easeOut(duration: 0.3), value: showLeaderboard)
        .onChange(of: showItemModal) {
            if showItemModal {
                self.playersForItems = self.extractPlayers()
            }
        }
        .onAppear {
            startTimer()
            self.playersForItems = self.extractPlayers()
        }
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            withAnimation(.linear(duration: 0.15)) {
                if remainingTime > 0 {
                    remainingTime -= 1
                } else {
                    timer.invalidate()
                }
            }
        }
    }
    
    private func scrollToTop() {
        if let firstMessage = sortedMessages.first {
            scrollProxy?.scrollTo(firstMessage.id, anchor: .top)
        }
    }
    

    
    // Static mode - comments and reactions are predefined
    // These functions are disabled for static testing
    
    private func extractPlayers() -> [Player] {
        let authors = Array(Set(messages.map { $0.author }))

        let players: [Player] = authors.compactMap { author in
            guard let latestMessageWithScore = messages.last(where: { $0.author == author && $0.score != nil }),
                  let scoreInfo = latestMessageWithScore.score else {
                return nil
            }
            
            return Player(
                name: author,
                image: latestMessageWithScore.authorImage,
                score: scoreInfo.score,
                rank: 0 // Rank will be recalculated after sorting
            )
        }
        
        // Sort players by score, descending
        let sortedPlayers = players.sorted { $0.score > $1.score }
        
        // Assign ranks based on the new sort order
        var finalPlayers = [Player]()
        for (index, player) in sortedPlayers.enumerated() {
            var rankedPlayer = player
            rankedPlayer.rank = index + 1
            finalPlayers.append(rankedPlayer)
        }
        
        return finalPlayers
    }
}

private func formatTimeRemaining(_ timeInterval: TimeInterval) -> String {
    let days = Int(timeInterval) / (24 * 3600)
    let hours = Int(timeInterval) % (24 * 3600) / 3600
    let minutes = Int(timeInterval) % 3600 / 60
    let seconds = Int(timeInterval) % 60
    return String(format: "%dd:%02dh:%02dm:%02ds", days, hours, minutes, seconds)
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

private func formatScore(_ value: Int) -> String {
    if value >= 1000 {
        let kValue = Double(value) / 1000.0
        return String(format: "%.1f", kValue).replacingOccurrences(of: ".0", with: "") + "k"
    }
    return "\(value)"
}

#Preview {
    ChatView()
} 