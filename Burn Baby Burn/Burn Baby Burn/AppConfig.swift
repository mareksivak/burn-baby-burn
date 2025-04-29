import Foundation

// MARK: - Author Configuration
struct Author: Identifiable {
    let id = UUID()
    let name: String
    let imageAsset: String
    let rank: Int
    let score: Int
}

// MARK: - Message Types
enum MessageType {
    case text(String)
    case jumboEmoji(String)
    case workout(WorkoutType, value: Int, calories: Int, mode: WorkoutMode)
}

// MARK: - Message Configuration
struct MessageConfig {
    let author: Author
    let type: MessageType
    let timeOffset: TimeInterval // offset in seconds from the base time
}

// MARK: - App Configuration
struct AppConfig {
    static let authors = [
        Author(name: "Ziga Porenta", imageAsset: "paul", rank: 1, score: 2458),
        Author(name: "Will Corbett", imageAsset: "will", rank: 4, score: 443),
        Author(name: "Christopher Schrader", imageAsset: "chris-h", rank: 2, score: 508),
        Author(name: "Nic", imageAsset: "nic", rank: 3, score: 806),
        Author(name: "Marek", imageAsset: "marek", rank: 5, score: 265)
    ]
    
    // Base time for the chat (18:54:00)
    static let baseTime: Date = {
        let calendar = Calendar.current
        let now = Date()
        return calendar.date(bySettingHour: 18, minute: 54, second: 0, of: now)!
    }()
    
    // Message sequence as displayed in chat
    static let messageSequence: [MessageConfig] = [
        // Initial workout by Ziga
        MessageConfig(
            author: authors[0], // Ziga
            type: .workout(.strengthTraining, value: 160, calories: 160, mode: .auto),
            timeOffset: 0
        ),
        
        // Will's reaction
        MessageConfig(
            author: authors[1], // Will
            type: .jumboEmoji("😮"),
            timeOffset: 34 * 60 // 34 minutes later
        ),
        
        // Chris's reaction
        MessageConfig(
            author: authors[2], // Chris
            type: .text("damn"),
            timeOffset: 3 * 3600 + 12 * 60 // 3h 12m later
        ),
        
        // Will's comment
        MessageConfig(
            author: authors[1], // Will
            type: .text("Somebody better get kamikaze"),
            timeOffset: 3 * 3600 + 47 * 60 // 3h 47m later
        ),
        
        // Will's workout
        MessageConfig(
            author: authors[1], // Will
            type: .workout(.strengthTraining, value: 179, calories: 238, mode: .manual),
            timeOffset: 4 * 3600 + 2 * 60 // 4h 2m later
        ),
        
        // Nic's reaction
        MessageConfig(
            author: authors[3], // Nic
            type: .text("Let's crush it! 💪"),
            timeOffset: 4 * 3600 + 15 * 60 // 4h 15m later
        ),
        
        // Marek's workout
        MessageConfig(
            author: authors[4], // Marek
            type: .workout(.running, value: 5000, calories: 320, mode: .auto),
            timeOffset: 4 * 3600 + 30 * 60 // 4h 30m later
        )
    ]
    
    // Helper function to convert config to Message model
    static func generateMessages() -> [Message] {
        return messageSequence.map { config in
            let timestamp = baseTime.addingTimeInterval(config.timeOffset)
            
            let content: String?
            let workout: Workout?
            
            switch config.type {
            case .text(let text):
                content = text
                workout = nil
            case .jumboEmoji(let emoji):
                content = emoji
                workout = nil
            case .workout(let type, let value, let calories, let mode):
                content = nil
                workout = Workout(type: type, value: value, calories: calories, mode: mode)
            }
            
            return Message(
                author: config.author.name,
                authorImage: config.author.imageAsset,
                content: content,
                workout: workout,
                timestamp: timestamp,
                score: (config.author.rank, config.author.score)
            )
        }
    }
} 