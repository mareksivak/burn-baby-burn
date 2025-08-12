import Foundation

struct Message: Identifiable {
    let id = UUID()
    let author: String
    let authorImage: String
    let content: String?
    let workout: Workout?
    let timestamp: Date
    let score: (rank: String, score: Int)?
    let location: String?
    let attachedImages: [String] // Array of image asset names (0-5 images)
    var comments: [Comment]
    var reactions: [Reaction] // Made mutable for dynamic reactions
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "Day 1(EEE), h:mm a"
        return formatter.string(from: timestamp)
    }
}

struct Comment: Identifiable {
    let id = UUID()
    let author: String
    let authorImage: String
    let content: String
    let timestamp: Date
}

struct Reaction: Identifiable {
    let id = UUID()
    let author: String
    let authorImage: String
    let type: ReactionType
    let timestamp: Date
}

enum ReactionType: String, CaseIterable {
    case like = "❤️"
    case fire = "🔥"
    case muscle = "💪"
    case clap = "👏"
    case rocket = "🚀"
    case crown = "👑"
    
    var displayName: String {
        switch self {
        case .like: return "Like"
        case .fire: return "Fire"
        case .muscle: return "Muscle"
        case .clap: return "Clap"
        case .rocket: return "Rocket"
        case .crown: return "Crown"
        }
    }
}

struct Workout: Identifiable {
    let id = UUID()
    let type: WorkoutType
    let value: Int
    let calories: Int
    let mode: WorkoutMode
    var items: [WorkoutItem] = []
    
    // New workout data fields
    let distance: Double? // in kilometers, nil for non-distance workouts
    let duration: TimeInterval // in seconds
    let avgHeartRate: Int? // in BPM, nil if not tracked
    let maxHeartRate: Int? // in BPM, nil if not tracked
    
    var finalScore: Int {
        var multiplier: Double = 1.0
        for item in items {
            switch item.item.effect {
            case .multiplyNextWorkout(let itemMultiplier):
                multiplier *= itemMultiplier
            default:
                break
            }
        }
        return Int(Double(calories) * multiplier)
    }
}

struct WorkoutItem: Identifiable {
    let id = UUID()
    let item: Item
    let usedBy: String // Player name who used the item
    let usedOn: String // Player name whose workout was affected
}

enum WorkoutType: String {
    case strengthTraining = "STRENGTH\nTRAINING"
    case running = "RUNNING"
    case walking = "WALKING"
    case swimming = "SWIMMING"
    case hiking = "HIKING"
    case coreTraining = "CORE\nTRAINING"
    case yoga = "YOGA"
    
    var icon: String {
        switch self {
        case .strengthTraining: return "figure.strengthtraining.traditional"
        case .running: return "figure.run"
        case .walking: return "figure.walk"
        case .swimming: return "figure.pool.swim"
        case .hiking: return "figure.hiking"
        case .coreTraining: return "figure.core.training"
        case .yoga: return "figure.yoga"
        }
    }
    
    var hasDistance: Bool {
        switch self {
        case .running, .walking, .swimming, .hiking:
            return true
        case .strengthTraining, .coreTraining, .yoga:
            return false
        }
    }
}

enum WorkoutMode: String {
    case auto = "AUTO"
    case manual = "MANUAL"
}

struct Player: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let image: String
    var score: Int
    var rank: Int
    let isCurrentPlayer: Bool
    
    init(name: String, image: String, score: Int, isCurrentPlayer: Bool = false, rank: Int = 0) {
        self.name = name
        self.image = image
        self.score = score
        self.isCurrentPlayer = isCurrentPlayer
        self.rank = rank
    }
} 