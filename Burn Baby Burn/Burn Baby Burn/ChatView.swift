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

#Preview {
    ChatView()
} 