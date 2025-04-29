import SwiftUI

struct ChatView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var remainingTime: TimeInterval
    @State private var messages: [Message] = AppConfig.generateMessages()
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
                        
                        VStack(alignment: .leading, spacing: 4) {
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