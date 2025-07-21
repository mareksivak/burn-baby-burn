import Foundation

struct Message: Identifiable {
    let id = UUID()
    let author: String
    let authorImage: String
    let content: String?
    let workout: Workout?
    let timestamp: Date
    let score: (rank: String, score: Int)?
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "Day 1(EEE), h:mm a"
        return formatter.string(from: timestamp)
    }
}

struct Workout: Identifiable {
    let id = UUID()
    let type: WorkoutType
    let value: Int
    let calories: Int
    let mode: WorkoutMode
}

enum WorkoutType: String {
    case strengthTraining = "STRENGTH\nTRAINING"
    case running = "RUNNING"
    case walking = "WALKING"
    case coreTraining = "CORE\nTRAINING"
    case yoga = "YOGA"
    
    var icon: String {
        switch self {
        case .strengthTraining: return "figure.strengthtraining.traditional"
        case .running: return "figure.run"
        case .walking: return "figure.walk"
        case .coreTraining: return "figure.core.training"
        case .yoga: return "figure.yoga"
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