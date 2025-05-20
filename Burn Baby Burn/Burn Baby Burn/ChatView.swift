import SwiftUI

struct ChatView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var remainingTime: TimeInterval
    @State private var messages: [Message] = AppConfig.generateMessages()
    @State private var scrollProxy: ScrollViewProxy? = nil
    @State private var inputText: String = ""
    @FocusState private var isInputFocused: Bool
    @State private var keyboardIsVisible: Bool = false
    @State private var keyboardHeight: CGFloat = 0
    
    private var safeAreaInset: CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
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
                .onTapGesture {
                    isInputFocused = false
                }
            
            VStack(spacing: 0) {
                // Top bar
                VStack(spacing: 0) {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
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
                        .padding(.bottom, keyboardHeight)
                    }
                    .onAppear {
                        scrollProxy = proxy
                        scrollToBottom()
                    }
                    .gesture(
                        DragGesture()
                            .onEnded { gesture in
                                if gesture.translation.height > 50 {
                                    isInputFocused = false
                                }
                            }
                    )
                }
                
                // Input bar
                VStack(spacing: 0) {
                    // First row: TextField
                    TextField(
                        "",
                        text: $inputText,
                        prompt: Text("Say hey")
                            .font(.custom("VT323-Regular", size: 22))
                            .foregroundColor(Colors.c0_500)
                    )
                    .font(.custom("VT323-Regular", size: 22))
                    .foregroundColor(Colors.c0_050)
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.20, green: 0.13, blue: 0.13))
                    .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44)
                    .cornerRadius(0)
                    .focused($isInputFocused)
                    .submitLabel(.send)
                    .onSubmit {
                        sendMessage()
                    }
                    // Add space between text input and buttons
                    Spacer().frame(height: 8)
                    // Second row: Actions and send arrow
                    HStack(spacing: 24) {
                        Button(action: {}) {
                            Image(systemName: "flame")
                                .font(.system(size: 16))
                                .frame(width: 38, height: 28)
                        }
                        Button(action: {}) {
                            Image(systemName: "photo")
                                .font(.system(size: 16))
                                .frame(width: 38, height: 28)
                        }
                        Button(action: {}) {
                            Image(systemName: "plus")
                                .font(.system(size: 16))
                                .frame(width: 38, height: 28)
                        }
                        Spacer()
                        if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Button(action: sendMessage) {
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(red: 0.20, green: 0.13, blue: 0.13))
                                    .frame(width: 38, height: 28)
                                    .background(Colors.c2_500)
                            }
                        }
                    }
                    .foregroundColor(Colors.c0_050)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, minHeight: 28, maxHeight: 28)
                    .background(Color(red: 0.20, green: 0.13, blue: 0.13))
                }
                .background(Color(red: 0.20, green: 0.13, blue: 0.13))
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: keyboardIsVisible ? 12 : 0)
                }
            }
        }
        .onAppear {
            startTimer()
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
                keyboardIsVisible = true
                if let keyboardFrame = (UIApplication.shared.windows.first?.rootViewController?.view.window?.inputViewController?.view.frame) {
                    keyboardHeight = keyboardFrame.height
                } else {
                    keyboardHeight = 300 // fallback
                }
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                keyboardIsVisible = false
                keyboardHeight = 0
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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
    
    private func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let newMessage = Message(
            author: "Will Corbett",
            authorImage: "will",
            content: trimmed,
            workout: nil,
            timestamp: Date(),
            score: messages.last(where: { $0.author == "Will Corbett" })?.score
        )
        messages.append(newMessage)
        inputText = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            scrollToBottom()
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