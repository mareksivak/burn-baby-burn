import SwiftUI

struct ChatView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var remainingTime: TimeInterval
    @State private var messages: [Message] = generateMessages()
    @State private var scrollProxy: ScrollViewProxy? = nil
    
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
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Colors.c0_050)
                        }
                        
                        HStack(spacing: 8) {
                            Text("Calorie Crushers")
                                .font(.custom("PressStart2P-Regular", size: 14))
                                .foregroundColor(Colors.c0_050)
                            
                            Text(formatTimeRemaining(remainingTime))
                                .font(.custom("VT323-Regular", size: 16))
                                .foregroundColor(Colors.c0_500)
                        }
                        
                        Spacer()
                    }
                }
                .padding()
                .background(Color(red: 0.15, green: 0.1, blue: 0.1))
                
                // Chat messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 20) {
                            ForEach(messages) { message in
                                MessageView(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding()
                    }
                    .onAppear {
                        scrollProxy = proxy
                        scrollToBottom()
                    }
                }
                
                // Input bar
                HStack {
                    Image(systemName: "flame")
                    Image(systemName: "person.2")
                    Image(systemName: "bolt")
                    
                    Button(action: {}) {
                        Text("Say hey")
                            .font(.custom("PressStart2P-Regular", size: 14))
                            .foregroundColor(Colors.c2_500)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Colors.c1_400)
                            .cornerRadius(8)
                    }
                }
                .font(.system(size: 24))
                .foregroundColor(Colors.c2_500)
                .padding()
                .background(Color(red: 0.15, green: 0.1, blue: 0.1))
            }
        }
        .onAppear {
            startTimer()
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
    
    private func scrollToBottom() {
        if let lastMessage = messages.last {
            scrollProxy?.scrollTo(lastMessage.id, anchor: .bottom)
        }
    }
}

struct MessageView: View {
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
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            Image(message.authorImage)
                .resizable()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(Circle().stroke(Colors.c1_400, lineWidth: 2))
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(message.author)
                        .foregroundColor(message.author == "Will Corbett" ? Color(red: 0.8, green: 0.3, blue: 0.3) : Colors.c2_500)
                        .font(.custom("VT323-Regular", size: 20))
                    
                    if let score = message.score {
                        HStack(spacing: 4) {
                            // Rank pill
                            Text("\(score.count)")
                                .font(.custom("VT323-Regular", size: 16))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(score.count == 1 ? Colors.c2_500 : Color(red: 0.3, green: 0.2, blue: 0.1))
                                .cornerRadius(12)
                                .foregroundColor(Colors.c0_050)
                            
                            // Score pill
                            Text("\(score.total)")
                                .font(.custom("VT323-Regular", size: 16))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(red: 0.3, green: 0.2, blue: 0.1), lineWidth: 1)
                                )
                                .foregroundColor(Colors.c0_050)
                        }
                    }
                }
                
                if let content = message.content {
                    if isJumboEmoji {
                        Text(content)
                            .font(.system(size: 48))
                    } else {
                        Text(content)
                            .font(.custom("VT323-Regular", size: 18))
                            .foregroundColor(Colors.c0_050)
                            .padding()
                            .background(Colors.c1_400)
                            .cornerRadius(12)
                    }
                }
                
                if let workout = message.workout {
                    HStack {
                        HStack(alignment: .firstTextBaseline) {
                            Image(systemName: workout.type.icon)
                                .font(.system(size: 24))
                            Text("\(workout.value)")
                                .font(.custom("PressStart2P-Regular", size: 24))
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("\(workout.calories) Cal")
                                .font(.custom("VT323-Regular", size: 16))
                            Text(workout.mode.rawValue)
                                .font(.custom("VT323-Regular", size: 14))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(red: 0.3, green: 0.2, blue: 0.1))
                                .cornerRadius(8)
                        }
                    }
                    .foregroundColor(Colors.c0_050)
                    .padding()
                    .background(Colors.c1_400)
                    .cornerRadius(12)
                    
                    Text(workout.type.rawValue)
                        .font(.custom("VT323-Regular", size: 16))
                        .foregroundColor(Colors.c0_050)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 16)
                }
            }
        }
    }
}

private func formatTimeRemaining(_ timeInterval: TimeInterval) -> String {
    let days = Int(timeInterval) / (24 * 3600)
    let hours = Int(timeInterval) % (24 * 3600) / 3600
    let minutes = Int(timeInterval) % 3600 / 60
    let seconds = Int(timeInterval) % 60
    return String(format: "%dd:%02dh:%02dm:%02ds", days, hours, minutes, seconds)
}

private func generateMessages() -> [Message] {
    let baseDate = Calendar.current.date(bySettingHour: 18, minute: 54, second: 0, of: Date())!
    var messages: [Message] = []
    
    // Initial conversation from screenshot
    messages += [
        Message(
            author: "Ziga Porenta",
            authorImage: "paul",
            content: nil,
            workout: Workout(type: .strengthTraining, value: 160, calories: 160, mode: .auto),
            timestamp: baseDate,
            score: (1, 2458)
        ),
        Message(
            author: "Will Corbett",
            authorImage: "will",
            content: "😮",
            workout: nil,
            timestamp: baseDate.addingTimeInterval(34 * 60),
            score: (4, 265)
        ),
        Message(
            author: "Christopher Schrader",
            authorImage: "chris-h",
            content: "damn",
            workout: nil,
            timestamp: baseDate.addingTimeInterval(3 * 3600 + 12 * 60),
            score: (2, 508)
        ),
        Message(
            author: "Will Corbett",
            authorImage: "will",
            content: "Somebody better get kamikaze",
            workout: nil,
            timestamp: baseDate.addingTimeInterval(3 * 3600 + 47 * 60),
            score: (4, 443)
        ),
        Message(
            author: "Will Corbett",
            authorImage: "will",
            content: nil,
            workout: Workout(type: .strengthTraining, value: 179, calories: 238, mode: .manual),
            timestamp: baseDate.addingTimeInterval(4 * 3600 + 2 * 60),
            score: (4, 443)
        )
    ]
    
    // Additional varied messages
    let users = [
        ("Ziga Porenta", "paul"),
        ("Will Corbett", "will"),
        ("Christopher Schrader", "chris-h"),
        ("Nic", "nic"),
        ("Marek", "marek")
    ]
    
    let workoutVariations: [(WorkoutType, ClosedRange<Int>, ClosedRange<Int>)] = [
        (.strengthTraining, 150...200, 150...300),
        (.running, 3000...10000, 200...500),
        (.walking, 2000...5000, 100...200),
        (.coreTraining, 50...150, 100...200),
        (.yoga, 30...60, 50...150)
    ]
    
    let reactions = [
        "Let's crush it! 💪",
        "Nice work!",
        "Impressive progress",
        "Keep it up! 🔥",
        "You're on fire",
        "Beast mode activated",
        "This is the way",
        "Legendary",
        "Time to level up",
        "Can't stop won't stop",
        "🚀",
        "💯",
        "🏆"
    ]
    
    for i in 0..<45 {
        let timeOffset = Double((i + 5) * 15 * 60) // 15-minute intervals
        let user = users.randomElement()!
        let isWorkout = Bool.random()
        
        if isWorkout {
            let workout = workoutVariations.randomElement()!
            messages.append(Message(
                author: user.0,
                authorImage: user.1,
                content: nil,
                workout: Workout(
                    type: workout.0,
                    value: Int.random(in: workout.1),
                    calories: Int.random(in: workout.2),
                    mode: Bool.random() ? .auto : .manual
                ),
                timestamp: baseDate.addingTimeInterval(timeOffset),
                score: (Int.random(in: 1...5), Int.random(in: 200...2500))
            ))
        } else {
            messages.append(Message(
                author: user.0,
                authorImage: user.1,
                content: reactions.randomElement()!,
                workout: nil,
                timestamp: baseDate.addingTimeInterval(timeOffset),
                score: (Int.random(in: 1...5), Int.random(in: 200...2500))
            ))
        }
    }
    
    return messages.sorted { $0.timestamp < $1.timestamp }
}

#Preview {
    ChatView()
} 