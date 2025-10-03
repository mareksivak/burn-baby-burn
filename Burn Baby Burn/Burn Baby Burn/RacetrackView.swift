import SwiftUI

struct RacetrackView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var scrollProxy: ScrollViewProxy? = nil
    @State private var showPlayerWorkouts: Bool = false
    @State private var selectedPlayer: Player? = nil
    @State private var showChat: Bool = false
    @State private var showMarkers: Bool = true
    @State private var remainingTime: TimeInterval
    @State private var roadOffset: CGFloat = 0
    
    // Player data with actual scores from workouts
    private var players: [Player] {
        let messages = AppConfig.generateMessages()
        let playerScores = Dictionary(grouping: messages.filter { $0.score != nil }, by: { $0.author })
            .mapValues { messages in
                messages.compactMap { $0.score?.score }.max() ?? 0
            }
        
        return [
            Player(name: "Will Corbett", image: "will", score: playerScores["Will Corbett"] ?? 0, isCurrentPlayer: true),
            Player(name: "Nic", image: "nic", score: playerScores["Nic"] ?? 0, isCurrentPlayer: false),
            Player(name: "Marek", image: "marek", score: playerScores["Marek"] ?? 0, isCurrentPlayer: false),
            Player(name: "Christopher Schrader", image: "chris-h", score: playerScores["Christopher Schrader"] ?? 0, isCurrentPlayer: false),
            Player(name: "Ziga Porenta", image: "paul", score: playerScores["Ziga Porenta"] ?? 0, isCurrentPlayer: false)
        ]
    }
    
    // Messages for workout data
    private let messages = AppConfig.generateMessages()
    
    init() {
        let days: TimeInterval = 2 * 24 * 3600  // 2 days
        let hours: TimeInterval = 10 * 3600     // 10 hours
        let minutes: TimeInterval = 5 * 60      // 5 minutes
        let seconds: TimeInterval = 30          // 30 seconds
        _remainingTime = State(initialValue: days + hours + minutes + seconds)
    }
    
    private var maxScore: Int {
        players.map { $0.score }.max() ?? AppConfig.racetrackLength
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
    
    // Viewport shows configured points of track
    private var viewportHeight: CGFloat {
        CGFloat(AppConfig.racetrackViewport) * 0.3 // Scale factor for viewport
    }
    
    // Calculate total track height based on configured track length
    private var totalTrackHeight: CGFloat {
        CGFloat(AppConfig.racetrackLength) * 0.3 // Scale factor for track length
    }
    
    // Calculate the scale factor for player positioning - 500 points = 400 pixels
    private var playerPositionScale: CGFloat {
        return 400.0 / 500.0  // 400 pixels per 500 points
    }
    
    // Calculate the base Y position for players (start track higher)
    private var playerBaseY: CGFloat {
        return 50  // Minimal padding from top
    }
    
    // Calculate the total height needed for the track with padding
    private var trackHeightWithPadding: CGFloat {
        let numberOfSegments = AppConfig.racetrackLength / 500  // 20 segments (0, 500, 1000, ..., 9500)
        let trackHeight = CGFloat(numberOfSegments) * 400  // 400px per segment
        return trackHeight + 250  // 50px top + 200px bottom padding
    }
    
    // Start the continuous road animation
    private func startRoadAnimation() {
        let roadHeight = UIScreen.main.bounds.width * 0.5
        
        // Reset to starting position
        roadOffset = 0
        
        // Animate from top to bottom (positive Y direction)
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            roadOffset = roadHeight
        }
    }
    
    var body: some View {
        ZStack {
            // Animated road background with seamless repetition
            GeometryReader { geometry in
                let roadHeight = geometry.size.width * 0.5
                let screenHeight = geometry.size.height
                let segmentsNeeded = Int(ceil(screenHeight / roadHeight)) + 2 // Extra segments for smooth scrolling
                
                VStack(spacing: 0) {
                    ForEach(0..<segmentsNeeded, id: \.self) { index in
                        Image("road")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: roadHeight)
                            .clipped()
                    }
                }
                .offset(y: roadOffset)
                .onAppear {
                    startRoadAnimation()
                }
            }
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
                        .padding(.leading, 12)
                        
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
                                // Rank/score box - tappable
                                Button(action: {
                                    // Find Will Corbett player and show their workouts
                                    if let willPlayer = players.first(where: { $0.name == "Will Corbett" }) {
                                        selectedPlayer = willPlayer
                                        showPlayerWorkouts = true
                                    }
                                }) {
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
                            }
                            .padding(.trailing, 12)
                        }
                    }
                }
                .padding(.vertical, 8)
                .background(Color(red: 0.15, green: 0.1, blue: 0.1))
                
                // Floating buttons
                HStack {
                    Spacer()
                    
                    // Markers toggle button
                    Button(action: {
                        showMarkers.toggle()
                    }) {
                        Image(systemName: showMarkers ? "line.3.horizontal" : "line.3.horizontal")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(showMarkers ? Colors.c2_500 : Colors.c0_050)
                            .frame(width: 44, height: 44)
                            .background(showMarkers ? Color(red: 0.20, green: 0.13, blue: 0.13) : Color(red: 0.15, green: 0.10, blue: 0.10))
                            .cornerRadius(0)
                    }
                    .padding(.trailing, 8)
                    
                    // Chat button
                    Button(action: {
                        showChat = true
                    }) {
                        Image(systemName: "message.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Colors.c0_050)
                            .frame(width: 44, height: 44)
                            .background(Color(red: 0.20, green: 0.13, blue: 0.13))
                            .cornerRadius(0)
                    }
                    .padding(.trailing, 16)
                }
                .padding(.top, 8)
                
                // Racetrack Content
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: true) {
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
                                            trackHeightWithPadding: trackHeightWithPadding,
                                            playerBaseY: playerBaseY,
                                            playerPositionScale: playerPositionScale,
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
                                .offset(y: trackHeightWithPadding - 2)
                                
                                // Debug markers every 500 points (highest at top) - conditional
                                if showMarkers {
                                    ForEach(0..<(AppConfig.racetrackLength / 500), id: \.self) { markerIndex in
                                        let milestone = AppConfig.racetrackLength - (markerIndex * 500)  // 10K at top, 0 at bottom
                                        let markerY = playerBaseY + (CGFloat(markerIndex) * 400)
                                        
                                        VStack(spacing: 2) {
                                            Rectangle()
                                                .fill(Colors.c1_400)
                                                .frame(height: 2)
                                                .frame(maxWidth: .infinity)
                                            
                                            Text("\(milestone)")
                                                .font(.custom("VT323-Regular", size: 10))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 4)
                                                .background(Color.black.opacity(0.7))
                                                .cornerRadius(2)
                                        }
                                        .position(x: UIScreen.main.bounds.width / 2, y: markerY)
                                    }
                                }
                                
                                // Lootboxes - placed 100 points before each player
                                ForEach(players) { player in
                                    let lootboxScore = player.score + 100  // 100 points before player
                                    let playerY = playerBaseY + (CGFloat((AppConfig.racetrackLength - player.score) / 500) * 400) + 25
                                    let lootboxY = playerY - 80  // 80px above player (100 points = 80px with new 400px scale)
                                    
                                    // Calculate which lane this player is in
                                    let sortedPlayers = players.sorted { $0.score > $1.score }
                                    let playersPerLane = max(1, sortedPlayers.count / 5)
                                    let playerIndex = sortedPlayers.firstIndex(where: { $0.id == player.id }) ?? 0
                                    let laneIndex = min(playerIndex / playersPerLane, 4)
                                    
                                    // Calculate X position for this lane
                                    let laneWidth = (UIScreen.main.bounds.width - 40) / 5
                                    let laneStartX = 20 + (CGFloat(laneIndex) * laneWidth) // 20px padding + lane offset
                                    let lootboxX = laneStartX + (laneWidth / 2) // Center of the lane
                                    
                                    Image("item-on-track")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .position(x: lootboxX, y: lootboxY)
                                }
                                
                                // Ghost - positioned at 5,300 points with horizontal movement
                                GhostSprite()
                                    .position(x: UIScreen.main.bounds.width / 2, y: playerBaseY + (CGFloat((AppConfig.racetrackLength - 5300) / 500) * 400))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: trackHeightWithPadding)
                        }
                        .frame(minHeight: UIScreen.main.bounds.height - 200)
                    }
                    .onAppear {
                        scrollProxy = proxy
                        // Auto-scroll to center current player (Will) in viewport
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if let currentPlayer = players.first(where: { $0.isCurrentPlayer }) {
                                // Calculate player position on the fixed track (highest scores at top)
                                let playerPosition = playerBaseY + (CGFloat((AppConfig.racetrackLength - currentPlayer.score) / 500) * 300) + 25
                                
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
        .sheet(isPresented: $showChat) {
            NavigationView {
                ChatView()
                    .navigationBarHidden(true)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
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
    let trackHeightWithPadding: CGFloat
    let playerBaseY: CGFloat
    let playerPositionScale: CGFloat
    let onPlayerTap: (Player) -> Void
    
    private var laneWidth: CGFloat {
        (UIScreen.main.bounds.width - 40) / 5 // 5 lanes, 20px padding on each side
    }
    
    var body: some View {
        ZStack {
            // Players positioned vertically in this virtual lane (highest scores at top)
            ForEach(players) { player in
                PlayerMarker(player: player) {
                    onPlayerTap(player)
                }
                .position(x: laneWidth / 2, y: playerBaseY + (CGFloat((AppConfig.racetrackLength - player.score) / 500) * 400) + 25)
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

// MARK: - Ghost Sprite Animation
struct GhostSprite: View {
    @State private var currentFrame = 0
    @State private var animationTimer: Timer?
    @State private var horizontalOffset: CGFloat = 0
    @State private var isMovingRight = true
    
    private let ghostImages = ["ghost1", "ghost2", "ghost3"]
    private let animationSpeed: TimeInterval = 0.5 // 0.5 seconds per frame
    private let movementSpeed: CGFloat = 1.0 // pixels per frame (slower movement)
    private let movementRange: CGFloat = 300 // total movement range (150px each side)
    
    var body: some View {
        Image(ghostImages[currentFrame])
            .resizable()
            .frame(width: 48, height: 48)
            .scaleEffect(x: isMovingRight ? 1 : -1, y: 1) // Flip horizontally when moving left
            .offset(x: horizontalOffset)
            .onAppear {
                startAnimations()
            }
            .onDisappear {
                stopAnimations()
            }
    }
    
    private func startAnimations() {
        // Start sprite animation
        animationTimer = Timer.scheduledTimer(withTimeInterval: animationSpeed, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.1)) {
                currentFrame = (currentFrame + 1) % ghostImages.count
            }
        }
        
        // Start horizontal movement animation
        startHorizontalMovement()
    }
    
    private func startHorizontalMovement() {
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
            withAnimation(.linear(duration: 0.016)) {
                if isMovingRight {
                    horizontalOffset += movementSpeed
                    if horizontalOffset >= movementRange / 2 {
                        isMovingRight = false
                    }
                } else {
                    horizontalOffset -= movementSpeed
                    if horizontalOffset <= -movementRange / 2 {
                        isMovingRight = true
                    }
                }
            }
        }
    }
    
    private func stopAnimations() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
}

#Preview {
    RacetrackView()
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