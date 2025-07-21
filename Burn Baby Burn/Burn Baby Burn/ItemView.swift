import SwiftUI
import Combine

// MARK: - Data Models

enum ItemRarity: String, CaseIterable {
    case common = "COMMON"
    case epic = "EPIC"
    case legendary = "LEGENDARY"

    var color: Color {
        switch self {
        case .common: return Color.gray
        case .epic: return Color.purple
        case .legendary: return Color.orange
        }
    }
}

enum ItemEffect {
    case deductPoints(points: Int)
    // Future effects can be added here
    // case swapWorkout
    // case resetScores
}

struct Item: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let description: String
    let imageName: String
    let rarity: ItemRarity
    let effect: ItemEffect

    static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id
    }
}




// MARK: - Item Flow Container View

struct ItemFlowView: View {
    @Binding var isPresented: Bool
    @State private var selectedItem: Item?
    @Binding var players: [Player]

    var body: some View {
        ZStack {
            Color(red: 0.13, green: 0.08, blue: 0.08).ignoresSafeArea()
            
            if let selectedItem = selectedItem {
                ItemDetailView(
                    isPresented: $isPresented,
                    item: selectedItem,
                    players: $players,
                    onBack: { self.selectedItem = nil }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            } else {
                ItemSelectionView(
                    isPresented: $isPresented,
                    onSelectItem: { item in
                        withAnimation(.easeInOut) {
                            self.selectedItem = item
                        }
                    }
                )
                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
            }
        }
    }
}


// MARK: - View 1: Item Selection Grid

struct ItemSelectionView: View {
    @Binding var isPresented: Bool
    var onSelectItem: (Item) -> Void
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Items")
                    .font(.custom("VT323-Regular", size: 24))
                    .foregroundColor(Colors.c0_050)
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Colors.c0_050)
                }
            }
            .padding()
            
            // Grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(ItemManager.shared.availableItems) { item in
                        ItemCard(item: item)
                            .onTapGesture {
                                onSelectItem(item)
                            }
                    }
                }
                .padding()
            }
        }
    }
}

struct ItemCard: View {
    let item: Item
    
    var body: some View {
        VStack(spacing: 8) {
            Image(item.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48, height: 48)
                .padding(8)
                .background(Color(red: 0.20, green: 0.13, blue: 0.13))
                .cornerRadius(0)
            
            Text(item.name)
                .font(.custom("VT323-Regular", size: 14))
                .foregroundColor(Colors.c0_050)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .padding(8)
        .background(Color(red: 0.20, green: 0.13, blue: 0.13))
        .cornerRadius(0)
    }
}


// MARK: - View 2: Item Detail & Targeting

struct ItemDetailView: View {
    @Binding var isPresented: Bool
    let item: Item
    @Binding var players: [Player]
    var onBack: () -> Void

    @State private var selectedPlayerId: UUID?
    @State private var previewScores: [UUID: Int]?
    @State private var originalPlayers: [Player]?
    @State private var barsVisible = false

    private var maxScore: Int {
        let scores = players.map { $0.score }
        if let previewScores = previewScores {
            let allPreviewScores = players.map { previewScores[$0.id] ?? $0.score }
            return (scores + allPreviewScores).max() ?? 1
        }
        return scores.max() ?? 1
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header is intentionally blank per design request

            // Item Info
            VStack(spacing: 16) {
                HStack {
                    Spacer()
                    Text(item.rarity.rawValue)
                        .font(.custom("VT323-Regular", size: 14))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(item.rarity.color)
                        .foregroundColor(.white)
                        .cornerRadius(0)
                }

                Image(item.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 80)

                Text(item.name)
                    .font(.custom("PressStart2P-Regular", size: 22))
                    .foregroundColor(Colors.c0_050)
                
                Text(item.description)
                    .font(.custom("VT323-Regular", size: 16))
                    .foregroundColor(Colors.c0_500)
            }
            .padding(.horizontal)
            .padding(.vertical, 24)
            .background(Color.black.opacity(0.2))

            // Leaderboard
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(players) { player in
                        PlayerRow(
                            player: player,
                            isSelected: player.id == selectedPlayerId,
                            previewScore: previewScores?[player.id],
                            maxScore: maxScore,
                            barsVisible: barsVisible
                        )
                        .onTapGesture {
                            handlePlayerSelection(player)
                        }
                    }
                }
                .padding()
            }

            // Action Button
            Spacer()
            if selectedPlayerId != nil {
                Button(action: {
                    // Use item logic
                    print("Used \(item.name) on player")
                    isPresented = false
                }) {
                    Text("USE \(item.name.uppercased())")
                        .font(.custom("VT323-Regular", size: 20))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(0)
                }
            } else {
                Text("SELECT TARGET")
                    .font(.custom("VT323-Regular", size: 20))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple.opacity(0.5))
                    .cornerRadius(0)
            }
        }
        .padding(.bottom)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.2)) {
                    barsVisible = true
                }
            }
        }
    }
    
    private func handlePlayerSelection(_ player: Player) {
        if player.id == selectedPlayerId {
            // Deselect
            selectedPlayerId = nil
            previewScores = nil
            if let originalPlayers = originalPlayers {
                withAnimation(.spring()) {
                    self.players = originalPlayers
                }
            }
            self.originalPlayers = nil
        } else {
            // Select
            if originalPlayers == nil {
                originalPlayers = players
            }
            selectedPlayerId = player.id
            calculatePreview()
        }
    }
    
    private func calculatePreview() {
        guard let targetPlayerId = selectedPlayerId,
              case .deductPoints(let points) = item.effect else {
            return
        }
        
        var newScores = players.reduce(into: [UUID: Int]()) { $0[$1.id] = $1.score }
        newScores[targetPlayerId]? -= points
        
        withAnimation(.spring()) {
            self.previewScores = newScores
            
            // Re-rank players based on preview
            let sortedPlayers = players.map { player -> Player in
                var newPlayer = player
                newPlayer.score = newScores[player.id] ?? player.score
                return newPlayer
            }.sorted { $0.score > $1.score }
            
            var rankedPlayers = [Player]()
            for (index, player) in sortedPlayers.enumerated() {
                var newPlayer = player
                newPlayer.rank = index + 1
                if let originalPlayerIndex = self.players.firstIndex(where: { $0.id == newPlayer.id }) {
                    self.players[originalPlayerIndex] = newPlayer
                }
            }
            
            self.players.sort { $0.rank < $1.rank }
        }
    }
}

struct PlayerRow: View {
    let player: Player
    let isSelected: Bool
    let previewScore: Int?
    let maxScore: Int
    let barsVisible: Bool
    
    private var originalScore: Int {
        if let previewScore = previewScore {
            // This assumes a deduction. More complex logic needed for other effects.
            return player.score + (player.score - previewScore)
        }
        return player.score
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Text("\(player.rank)")
                .font(.custom("VT323-Regular", size: 18))
                .frame(width: 20)
            
            Image(player.image)
                .resizable()
                .frame(width: 32, height: 32)
                .clipShape(Circle())

            Text(player.name)
                .font(.custom("VT323-Regular", size: 18))
            
            Spacer()
            
            // Score and Bar
            VStack(alignment: .trailing) {
                Text("\(player.score)")
                    .font(.custom("VT323-Regular", size: 18))
                ScoreBar(
                    score: player.score,
                    maxScore: maxScore,
                    previewScore: isSelected ? self.previewScore : nil,
                    barsVisible: barsVisible
                )
                .frame(height: 8)
            }
            .frame(width: 100)
        }
        .padding()
        .background(isSelected ? Color.red.opacity(0.5) : Color.black.opacity(0.2))
        .cornerRadius(0)
    }
}

struct ScoreBar: View {
    let score: Int
    let maxScore: Int
    let previewScore: Int?
    let barsVisible: Bool

    @State private var pulseOn = false
    @State private var pulsingActive = false

    var body: some View {
        GeometryReader { geo in
            let displayScore = barsVisible ? score : 0
            let displayPreview = barsVisible ? previewScore : nil

            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.3))

                if let preview = displayPreview, preview < displayScore {
                    let newScoreWidth = CGFloat(preview) / CGFloat(maxScore) * geo.size.width
                    let deductedAmount = displayScore - preview
                    let deductedWidth = CGFloat(deductedAmount) / CGFloat(maxScore) * geo.size.width

                    Rectangle()
                        .frame(width: newScoreWidth, height: geo.size.height)
                        .foregroundColor(.red)

                    Rectangle()
                        .frame(width: deductedWidth, height: geo.size.height * 1.2)
                        .foregroundColor(Color(red: 0.4, green: 0, blue: 0))
                        .opacity(pulseOn ? 1.0 : 0.3)
                        .offset(x: newScoreWidth, y: -(geo.size.height * 0.1))
                        .animation(.easeInOut(duration: 0.7), value: pulseOn)
                } else {
                    let scoreWidth = CGFloat(displayScore) / CGFloat(maxScore) * geo.size.width
                    Rectangle()
                        .frame(width: scoreWidth, height: geo.size.height)
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            updatePulsing()
        }
        .onChange(of: previewScore) { _ in
            updatePulsing()
        }
    }

    private func updatePulsing() {
        if previewScore != nil {
            pulsingActive = true
            startPulsing()
        } else {
            pulsingActive = false
        }
    }

    private func startPulsing() {
        guard pulsingActive else { pulseOn = false; return }
        withAnimation(.easeInOut(duration: 0.7)) {
            pulseOn.toggle()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            if pulsingActive {
                startPulsing()
            } else {
                pulseOn = false
            }
        }
    }
}

// MARK: - Item Manager

class ItemManager {
    static let shared = ItemManager()
    
    @Published var availableItems: [Item] = []
    
    private init() {
        setupDefaultItems()
    }
    
    private func setupDefaultItems() {
        availableItems = [
            Item(
                name: "Om Nom Nom",
                description: "Takes 300pts from target.",
                imageName: "item-omnomnom",
                rarity: .epic,
                effect: .deductPoints(points: 300)
            ),
            Item(
                name: "Energy Boost",
                description: "Gives you an extra burst of energy.",
                imageName: "item-energy-boost",
                rarity: .common,
                effect: .deductPoints(points: 10) // Placeholder effect
            ),
            Item(
                name: "Time Warp",
                description: "Bends time itself.",
                imageName: "item-time-warp",
                rarity: .legendary,
                effect: .deductPoints(points: 500) // Placeholder effect
            )
        ]
    }
}


// MARK: - Previews

struct ItemFlowView_Previews: PreviewProvider {
    static var previews: some View {
        ItemFlowView(isPresented: .constant(true), players: .constant([
            Player(name: "Player A", image: "avatar1", score: 1234, rank: 1),
            Player(name: "Player B", image: "avatar2", score: 1234, rank: 2),
            Player(name: "Player C", image: "avatar3", score: 1234, rank: 3),
            Player(name: "Player D", image: "avatar4", score: 1234, rank: 4)
        ]))
    }
} 