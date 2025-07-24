import SwiftUI

struct PlayerWorkoutsView: View {
    @Environment(\.dismiss) private var dismiss
    let player: Player
    let messages: [Message]
    
    init(player: Player, messages: [Message]) {
        self.player = player
        self.messages = messages
        print("PlayerWorkoutsView: Initialized for \(player.name) with \(messages.count) messages")
    }
    
    private var playerWorkouts: [Message] {
        let workouts = messages.filter { $0.author == player.name && $0.workout != nil }
        print("PlayerWorkoutsView: Found \(workouts.count) workouts for \(player.name)")
        return workouts
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.13, green: 0.08, blue: 0.08)
                .ignoresSafeArea()
            
            // Debug: Add a test text to see if view is rendering
            VStack {
                Text("DEBUG: View is rendering")
                    .foregroundColor(.red)
                    .font(.title)
                Text("Player: \(player.name)")
                    .foregroundColor(.red)
                Text("Workouts: \(playerWorkouts.count)")
                    .foregroundColor(.red)
            }
            .zIndex(1000) // Make sure it's on top
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image("back")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Colors.c0_050)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text(player.name.uppercased())
                            .font(.custom("PressStart2P-Regular", size: 16))
                            .foregroundColor(Colors.c2_500)
                        
                        Text("WORKOUTS")
                            .font(.custom("PressStart2P-Regular", size: 12))
                            .foregroundColor(Colors.c0_500)
                    }
                    
                    Spacer()
                    
                    // Player avatar
                    Image(player.image)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(
                                    player.isCurrentPlayer ? 
                                    AnyShapeStyle(LinearGradient(
                                        colors: [Colors.c2_500, Colors.c1_400, Colors.c0_500],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )) : AnyShapeStyle(Colors.c1_400),
                                    lineWidth: player.isCurrentPlayer ? 2 : 1
                                )
                        )
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                // Workouts list
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        ForEach(playerWorkouts) { message in
                            MessageView(message: message)
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    let samplePlayer = Player(name: "Will Corbett", image: "will", score: 3268, isCurrentPlayer: true)
    let sampleMessages = AppConfig.generateMessages()
    PlayerWorkoutsView(player: samplePlayer, messages: sampleMessages)
} 