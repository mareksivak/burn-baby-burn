import SwiftUI

struct MainScreen: View {
    @State private var showingChat = false
    
    // Break down calculations into constants
    private let day: TimeInterval = 24 * 3600
    private let hour: TimeInterval = 3600
    private let minute: TimeInterval = 60
    
    @State private var timeRemaining1: TimeInterval = {
        let days = 2 * (24 * 3600)
        let hours = 10 * 3600
        let minutes = 5 * 60
        return TimeInterval(days + hours + minutes + 30)
    }()
    
    @State private var timeRemaining2: TimeInterval = {
        let days = 1 * (24 * 3600)
        let hours = 5 * 3600
        let minutes = 30 * 60
        return TimeInterval(days + hours + minutes + 15)
    }()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.13, green: 0.08, blue: 0.08) // Dark brown background
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Top right invite code
                    HStack {
                        Spacer()
                        Text("INVITE CODE")
                            .font(.custom("VT323-Regular", size: 20))
                            .foregroundColor(Colors.c2_500)
                            .padding(.top, 10)
                            .padding(.trailing, 20)
                    }
                    
                    // Games Section
                    VStack(spacing: 15) {
                        Button(action: { showingChat = true }) {
                            GameCard(
                                profileImages: ["will", "chris-h", "nic", "paul", "marek"],
                                title: "Calorie Crushers",
                                subtitle: "Will Corbett I shouldn't have played Socialism",
                                timeStatus: formatTimeRemaining(timeRemaining1)
                            )
                        }
                        
                        GameCard(
                            profileImages: ["chris-h", "will", "nic", "paul", "marek"],
                            title: "Endurance Ellites",
                            subtitle: "Christopher Schrader literally the furst game ive won with Ziga",
                            timeStatus: formatTimeRemaining(timeRemaining2)
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Bottom Navigation
                    HStack {
                        NavigationButton(title: "Games", icon: "ellipsis.bubble.fill", isActive: true)
                        NavigationButton(title: "New Game", icon: "plus.circle.fill", isActive: false)
                        NavigationButton(title: "Profile", icon: "person.crop.circle.fill", isActive: false)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                }
            }
            .fullScreenCover(isPresented: $showingChat) {
                ChatView()
            }
            .onAppear {
                startTimer()
            }
        }
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            withAnimation {
                if timeRemaining1 > 0 {
                    timeRemaining1 -= 1
                }
                if timeRemaining2 > 0 {
                    timeRemaining2 -= 1
                }
            }
        }
    }
}

struct GameCard: View {
    let profileImages: [String]
    let title: String
    let subtitle: String
    var timeStatus: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Profile Images
            HStack(spacing: -8) {
                ForEach(profileImages, id: \.self) { imageName in
                    Image(imageName)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Colors.c1_400, lineWidth: 2))
                }
            }
            
            // Title and Subtitle
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("PressStart2P-Regular", size: 16))
                    .foregroundColor(Colors.c0_050)
                Text(subtitle)
                    .font(.custom("VT323-Regular", size: 18))
                    .foregroundColor(Colors.c0_500)
                    .lineLimit(1)
            }
            
            Text(timeStatus)
                .font(.custom("VT323-Regular", size: 16))
                .foregroundColor(Colors.c0_050)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Colors.c1_400)
        .cornerRadius(0)
    }
}

struct NavigationButton: View {
    let title: String
    let icon: String
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 24))
            Text(title)
                .font(.custom("PressStart2P-Regular", size: 10))
        }
        .foregroundColor(isActive ? Colors.c2_500 : Colors.c0_050)
        .frame(maxWidth: .infinity)
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
    MainScreen()
} 