import SwiftUI

struct RacetrackView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var scrollProxy: ScrollViewProxy? = nil
    @State private var showPlayerWorkouts: Bool = false
    @State private var selectedPlayer: Player? = nil
    
    // Player data with actual scores from workouts
    private let players = [
        Player(name: "Will Corbett", image: "will", score: 3268, isCurrentPlayer: true),
        Player(name: "Nic", image: "nic", score: 3280, isCurrentPlayer: false),
        Player(name: "Marek", image: "marek", score: 2890, isCurrentPlayer: false),
        Player(name: "Christopher Schrader", image: "chris-h", score: 2310, isCurrentPlayer: false),
        Player(name: "Ziga Porenta", image: "paul", score: 1440, isCurrentPlayer: false)
    ]
    
    // Messages for workout data
    private let messages = AppConfig.generateMessages()
    
    private var maxScore: Int {
        players.map { $0.score }.max() ?? 3280
    }
    
    // Virtual lanes - players assigned to 5 lanes based on score ranking
    private var playersByLane: [[Player]] {
        let sortedPlayers = players.sorted { $0.score > $1.score }
        let playersPerLane = max(1, sortedPlayers.count / 5)
        
        var lanes: [[Player]] = Array(repeating: [], count: 5)
        
        for (index, player) in sortedPlayers.enumerated() {
            let laneIndex = min(index / playersPerLane, 4)
            lanes[laneIndex].append(player)
        }
        
        return lanes
    }
    
    // Viewport shows 1500 points of track
    private let viewportHeight: CGFloat = 1500 * 0.1 // Scale factor for 1500 points
    
    // Calculate total track height
    private var totalTrackHeight: CGFloat {
        CGFloat(maxScore) * 0.1
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.13, green: 0.08, blue: 0.08) // Dark brown background
                .ignoresSafeArea()
            
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
                    
                    Text("RACETRACK")
                        .font(.custom("PressStart2P-Regular", size: 20))
                        .foregroundColor(Colors.c2_500)
                    
                    Spacer()
                    
                    // Placeholder for potential menu or settings button
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 24, height: 24)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                // Racetrack Content
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 0) {
                            // Track container with full height
                            ZStack {
                                // Virtual lanes - no visual indicators
                                HStack(spacing: 0) {
                                    ForEach(0..<5, id: \.self) { laneIndex in
                                        VirtualLaneView(
                                            laneIndex: laneIndex,
                                            players: playersByLane[laneIndex],
                                            maxScore: maxScore,
                                            totalTrackHeight: totalTrackHeight,
                                            onPlayerTap: { player in
                                                print("RacetrackView: Player tapped: \(player.name)")
                                                selectedPlayer = player
                                                showPlayerWorkouts = true
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                                
                                // Start line at bottom of track
                                HStack {
                                    Rectangle()
                                        .fill(Colors.c2_500)
                                        .frame(height: 4)
                                    Text("START")
                                        .font(.custom("PressStart2P-Regular", size: 12))
                                        .foregroundColor(Colors.c2_500)
                                        .padding(.leading, 8)
                                    Spacer()
                                }
                                .offset(y: totalTrackHeight - 2)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: totalTrackHeight)
                        }
                        .frame(minHeight: UIScreen.main.bounds.height - 200)
                    }
                    .onAppear {
                        scrollProxy = proxy
                        // Auto-scroll to center current player (Will) in viewport
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if let currentPlayer = players.first(where: { $0.isCurrentPlayer }) {
                                let currentPlayerY = totalTrackHeight - (CGFloat(currentPlayer.score) * 0.1)
                                let targetY = currentPlayerY - (viewportHeight / 2) // Center in viewport
                                
                                withAnimation(.easeInOut(duration: 1.0)) {
                                    proxy.scrollTo(currentPlayer.id, anchor: .center)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
        }
        .sheet(isPresented: $showPlayerWorkouts) {
            if let selectedPlayer = selectedPlayer {
                NavigationView {
                    PlayerWorkoutsView(player: selectedPlayer, messages: messages)
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
        .onChange(of: showPlayerWorkouts) { isPresented in
            if isPresented, let selectedPlayer = selectedPlayer {
                print("RacetrackView: Presenting sheet for \(selectedPlayer.name)")
            }
        }
    }
}

struct VirtualLaneView: View {
    let laneIndex: Int
    let players: [Player]
    let maxScore: Int
    let totalTrackHeight: CGFloat
    let onPlayerTap: (Player) -> Void
    
    private var laneWidth: CGFloat {
        (UIScreen.main.bounds.width - 40) / 5 // 5 lanes, 20px padding on each side
    }
    
    var body: some View {
        ZStack {
            // Players positioned vertically in this virtual lane
            ForEach(players) { player in
                PlayerMarker(player: player) {
                    onPlayerTap(player)
                }
                .offset(y: totalTrackHeight - (CGFloat(player.score) * 0.1) - 25)
            }
        }
        .frame(width: laneWidth)
    }
}

struct PlayerMarker: View {
    let player: Player
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            // Player avatar
            Image(player.image)
                .resizable()
                .frame(width: 50, height: 50)
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
                            lineWidth: player.isCurrentPlayer ? 3 : 2
                        )
                )
                .shadow(color: player.isCurrentPlayer ? Colors.c2_500.opacity(0.5) : Color.clear, radius: 8)
            
            // Score display
            Text("\(player.score)")
                .font(.custom("VT323-Regular", size: 16))
                .foregroundColor(Colors.c0_050)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Colors.c1_400)
                .cornerRadius(4)
            
            // Current player indicator
            if player.isCurrentPlayer {
                Image(systemName: "arrow.down")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Colors.c2_500)
            }
        }
        .id(player.id)
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    RacetrackView()
} 