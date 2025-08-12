import Foundation

// MARK: - Author Configuration
struct Author: Identifiable {
    let id = UUID()
    let name: String
    let imageAsset: String
    var score: Int
    var rank: String
    
    init(name: String, imageAsset: String) {
        self.name = name
        self.imageAsset = imageAsset
        self.score = 0
        self.rank = "-"
    }
}

// MARK: - Message Types
enum MessageType {
    case text(String)
    case jumboEmoji(String)
    case workout(WorkoutType, mode: WorkoutMode, value: Int, calories: Int, distance: Double?, duration: TimeInterval, avgHeartRate: Int?, maxHeartRate: Int?, items: [WorkoutItemConfig])
}

// MARK: - Message Configuration
struct MessageConfig {
    let authorName: String
    let type: MessageType
    let timeOffset: TimeInterval // offset in seconds from the base time
    let reactions: [ReactionConfig]
    let comments: [CommentConfig]
    let attachedImages: [String] // Array of image asset names (0-5 images)
}

// MARK: - Workout Item Configuration
struct WorkoutItemConfig {
    let itemName: String
    let usedBy: String
    let usedOn: String
}

// MARK: - Comment Configuration
struct CommentConfig {
    let author: String
    let content: String
    let timeOffset: TimeInterval
}

// MARK: - Reaction Configuration
struct ReactionConfig {
    let author: String
    let type: ReactionType
    let timeOffset: TimeInterval
}

// MARK: - App Configuration
struct AppConfig {
    static var authors = [
        Author(name: "Ziga Porenta", imageAsset: "paul"),
        Author(name: "Will Corbett", imageAsset: "will"),
        Author(name: "Christopher Schrader", imageAsset: "chris-h"),
        Author(name: "Nic", imageAsset: "nic"),
        Author(name: "Marek", imageAsset: "marek")
    ]
    
    // Base time for the chat (18:54:00)
    static let baseTime: Date = {
        let calendar = Calendar.current
        let now = Date()
        return calendar.date(bySettingHour: 18, minute: 54, second: 0, of: now)!
    }()
    
    // Helper function to update ranks based on current scores
    private static func updateRanks() {
        // Sort authors by score (descending) and then by name
        let sorted = authors.enumerated().sorted { 
            if $0.element.score == $1.element.score {
                return $0.element.name < $1.element.name
            }
            return $0.element.score > $1.element.score
        }
        var currentRank = 1
        var currentScore = -1
        var currentRankCount = 0
        for (sortedIndex, sortedAuthor) in sorted.enumerated() {
            let i = authors.firstIndex(where: { $0.name == sortedAuthor.element.name })!
            if authors[i].score == 0 {
                authors[i].rank = "-"
            } else if authors[i].score == currentScore {
                authors[i].rank = String(currentRank)
                currentRankCount += 1
            } else {
                currentRank += currentRankCount
                currentRankCount = 1
                currentScore = authors[i].score
                authors[i].rank = String(currentRank)
            }
        }
    }
    
    // Helper function to get location for author
    private static func getLocationForAuthor(_ authorName: String) -> String {
        let locations = ["Gym", "Home", "Park", "Studio", "Outdoors", "Fitness Center"]
        // Use author name to generate consistent location
        let hash = abs(authorName.hashValue)
        return locations[hash % locations.count]
    }
    
    // Helper function to convert config to Message model
    static func generateMessages() -> [Message] {
        // Reset all authors' scores and ranks
        for i in 0..<authors.count {
            authors[i].score = 0
            authors[i].rank = "-"
        }
        
        return messageSequence.map { config in
            let timestamp = baseTime.addingTimeInterval(config.timeOffset)
            
            let content: String?
            var workout: Workout?
            
            var authorImage = ""
            var authorRank = "-"
            var authorScore = 0
            if let authorIndex = authors.firstIndex(where: { $0.name == config.authorName }) {
                authorImage = authors[authorIndex].imageAsset
                authorRank = authors[authorIndex].rank
                authorScore = authors[authorIndex].score
            }
            
            switch config.type {
            case .text(let text):
                content = text
                workout = nil
            case .jumboEmoji(let emoji):
                content = emoji
                workout = nil
            case .workout(let type, let mode, let value, let calories, let distance, let duration, let avgHeartRate, let maxHeartRate, let items):
                content = nil
                var newWorkout = Workout(type: type, value: value, calories: calories, mode: mode, distance: distance, duration: duration, avgHeartRate: avgHeartRate, maxHeartRate: maxHeartRate)
                
                // Add items to workout based on configuration
                newWorkout.items = items.map { itemConfig in
                    let item = ItemManager.shared.availableItems.first { $0.name == itemConfig.itemName }!
                    return WorkoutItem(item: item, usedBy: itemConfig.usedBy, usedOn: itemConfig.usedOn)
                }
                
                // Update score for workout using finalScore (with items applied)
                if let authorIndex = authors.firstIndex(where: { $0.name == config.authorName }) {
                    authors[authorIndex].score += newWorkout.finalScore
                    updateRanks()
                    authorRank = authors[authorIndex].rank
                    authorScore = authors[authorIndex].score
                }
                
                workout = newWorkout
            }
            
            // Generate comments and reactions from config
            let comments = config.comments.map { commentConfig in
                let commentTime = timestamp.addingTimeInterval(commentConfig.timeOffset)
                return Comment(
                    author: commentConfig.author,
                    authorImage: authors.first(where: { $0.name == commentConfig.author })?.imageAsset ?? "will",
                    content: commentConfig.content,
                    timestamp: commentTime
                )
            }
            
            let reactions = config.reactions.map { reactionConfig in
                let reactionTime = timestamp.addingTimeInterval(reactionConfig.timeOffset)
                return Reaction(
                    author: reactionConfig.author,
                    authorImage: authors.first(where: { $0.name == reactionConfig.author })?.imageAsset ?? "will",
                    type: reactionConfig.type,
                    timestamp: reactionTime
                )
            }
            
            return Message(
                author: config.authorName,
                authorImage: authorImage,
                content: content,
                workout: workout,
                timestamp: timestamp,
                score: (authorRank, authorScore),
                location: getLocationForAuthor(config.authorName),
                attachedImages: config.attachedImages,
                comments: comments,
                reactions: reactions
            )
        }
    }
    
    // Message sequence as displayed in chat
    static let messageSequence: [MessageConfig] = [
        // Initial workout by Ziga
        MessageConfig(
            authorName: "Ziga Porenta",
            type: .workout(.strengthTraining, mode: .auto, value: 160, calories: 160, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: []),
            timeOffset: 0,
            reactions: [
                ReactionConfig(author: "Will Corbett", type: .fire, timeOffset: 2 * 60),
                ReactionConfig(author: "Nic", type: .muscle, timeOffset: 5 * 60),
                ReactionConfig(author: "Nic", type: .muscle, timeOffset: 5 * 60),
                ReactionConfig(author: "Marek", type: .like, timeOffset: 8 * 60)
            ],
            comments: [
                CommentConfig(author: "Will Corbett", content: "damn", timeOffset: 34 * 60),
                CommentConfig(author: "Christopher Schrader", content: "Nice work! 💪", timeOffset: 3 * 3600 + 12 * 60)
            ],
            attachedImages: ["photo1", "photo2"]
        ),
        
        // Will's reaction
        MessageConfig(
            authorName: "Will Corbett",
            type: .jumboEmoji("😮"),
            timeOffset: 34 * 60, // 34 minutes later
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        // Chris's reaction
        MessageConfig(
            authorName: "Christopher Schrader",
            type: .text("damn"),
            timeOffset: 3 * 3600 + 12 * 60, // 3h 12m later
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        // Will's comment
        MessageConfig(
            authorName: "Will Corbett",
            type: .text("Somebody better get kamikaze"),
            timeOffset: 3 * 3600 + 47 * 60, // 3h 47m later
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        // Will's workout with items
        MessageConfig(
            authorName: "Will Corbett",
            type: .workout(.strengthTraining, mode: .manual, value: 238, calories: 238, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: []),
            timeOffset: 4 * 3600 + 2 * 60, // 4h 2m later
            reactions: [
                ReactionConfig(author: "Christopher Schrader", type: .clap, timeOffset: 1 * 60),
                ReactionConfig(author: "Ziga Porenta", type: .rocket, timeOffset: 3 * 60)
            ],
            comments: [
                CommentConfig(author: "Nic", content: "Let's crush it! 💪", timeOffset: 4 * 3600 + 15 * 60),
                CommentConfig(author: "Marek", content: "Keep it up! 🔥", timeOffset: 4 * 3600 + 20 * 60)
            ],
            attachedImages: ["photo1", "photo3", "photo5"]
        ),
        
        // Nic's reaction
        MessageConfig(
            authorName: "Nic",
            type: .text("Let's crush it! 💪"),
            timeOffset: 4 * 3600 + 15 * 60, // 4h 15m later
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        // Marek's workout with items
        MessageConfig(
            authorName: "Marek",
            type: .workout(.running, mode: .auto, value: 320, calories: 320, distance: 3.2, duration: 18 * 60, avgHeartRate: 155, maxHeartRate: 175, items: []),
            timeOffset: 4 * 3600 + 30 * 60, // 4h 30m later
            reactions: [
                ReactionConfig(author: "Will Corbett", type: .fire, timeOffset: 2 * 60),
                ReactionConfig(author: "Nic", type: .muscle, timeOffset: 4 * 60)
            ],
            comments: [
                CommentConfig(author: "Christopher Schrader", content: "Amazing progress! 👏", timeOffset: 4 * 3600 + 35 * 60)
            ],
            attachedImages: []
        ),
        
        // Will's 1100 calorie run with items
        MessageConfig(
            authorName: "Will Corbett",
            type: .workout(.running, mode: .manual, value: 1100, calories: 1100, distance: 10.5, duration: 52 * 60, avgHeartRate: 165, maxHeartRate: 185, items: [
                WorkoutItemConfig(itemName: "Quicksand", usedBy: "Marek", usedOn: "Will Corbett"),
                WorkoutItemConfig(itemName: "Roid Rage", usedBy: "Will Corbett", usedOn: "Will Corbett")
            ]),
            timeOffset: 16 * 3600 + 30 * 60,
            reactions: [
                ReactionConfig(author: "Christopher Schrader", type: .crown, timeOffset: 2 * 60),
                ReactionConfig(author: "Marek", type: .clap, timeOffset: 5 * 60)
            ],
            comments: [
                CommentConfig(author: "Nic", content: "Beast mode! 💪", timeOffset: 5 * 60),
                CommentConfig(author: "Ziga Porenta", content: "You're crushing it! 🚀", timeOffset: 10 * 60)
            ],
            attachedImages: []
        ),
        
        // Marek's walking workout with items
        MessageConfig(
            authorName: "Marek",
            type: .workout(.walking, mode: .manual, value: 450, calories: 450, distance: 6.8, duration: 1 * 3600 + 45 * 60, avgHeartRate: 110, maxHeartRate: 135, items: [
                WorkoutItemConfig(itemName: "Quicksand", usedBy: "Ziga Porenta", usedOn: "Marek"),
                WorkoutItemConfig(itemName: "Quicksand", usedBy: "Will Corbett", usedOn: "Marek")
            ]),
            timeOffset: 15 * 3600 + 45 * 60,
            reactions: [
                ReactionConfig(author: "Will Corbett", type: .fire, timeOffset: 2 * 60),
                ReactionConfig(author: "Nic", type: .muscle, timeOffset: 4 * 60)
            ],
            comments: [
                CommentConfig(author: "Christopher Schrader", content: "Keep it up! 🔥", timeOffset: 3 * 60)
            ],
            attachedImages: []
        ),
        
        // Christopher's core training with items
        MessageConfig(
            authorName: "Christopher Schrader",
            type: .workout(.coreTraining, mode: .auto, value: 450, calories: 450, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: [
                WorkoutItemConfig(itemName: "Arnold's Pills", usedBy: "Christopher Schrader", usedOn: "Christopher Schrader")
            ]),
            timeOffset: 15 * 3600 + 30 * 60,
            reactions: [
                ReactionConfig(author: "Will Corbett", type: .crown, timeOffset: 2 * 60),
                ReactionConfig(author: "Marek", type: .clap, timeOffset: 5 * 60)
            ],
            comments: [
                CommentConfig(author: "Ziga Porenta", content: "You're crushing it! 🚀", timeOffset: 5 * 3600 + 30 * 60)
            ],
            attachedImages: ["photo1", "photo2", "photo3", "photo4", "photo5"]
        ),
        
        // Additional static messages to reach 100
        MessageConfig(
            authorName: "Ziga Porenta",
            type: .workout(.coreTraining, mode: .auto, value: 150, calories: 150, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: []),
            timeOffset: 5 * 3600,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Christopher Schrader",
            type: .text("Nice work! 💪"),
            timeOffset: 5 * 3600 + 15 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Nic",
            type: .workout(.yoga, mode: .manual, value: 120, calories: 120, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: []),
            timeOffset: 5 * 3600 + 30 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Will Corbett",
            type: .text("Let's do a group workout! 🏋️‍♂️"),
            timeOffset: 5 * 3600 + 45 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Marek",
            type: .workout(.strengthTraining, mode: .auto, value: 250, calories: 250, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: []),
            timeOffset: 6 * 3600,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Ziga Porenta",
            type: .text("Beast mode! 🔥"),
            timeOffset: 6 * 3600 + 10 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Nic",
            type: .workout(.running, mode: .manual, value: 450, calories: 450, distance: 4.8, duration: 25 * 60, avgHeartRate: 160, maxHeartRate: 180, items: []),
            timeOffset: 6 * 3600 + 30 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Christopher Schrader",
            type: .text("New personal best! 🏆"),
            timeOffset: 6 * 3600 + 35 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Will Corbett",
            type: .workout(.coreTraining, mode: .auto, value: 180, calories: 180, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: []),
            timeOffset: 6 * 3600 + 45 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Marek",
            type: .text("Keep the momentum! 💫"),
            timeOffset: 7 * 3600,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Ziga Porenta",
            type: .workout(.yoga, mode: .manual, value: 150, calories: 150, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: []),
            timeOffset: 7 * 3600 + 15 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Nic",
            type: .text("Perfect form! 🧘‍♂️"),
            timeOffset: 7 * 3600 + 20 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Christopher Schrader",
            type: .workout(.strengthTraining, mode: .auto, value: 280, calories: 280, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: []),
            timeOffset: 7 * 3600 + 30 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Will Corbett",
            type: .text("Absolute beast mode! 🦁"),
            timeOffset: 7 * 3600 + 35 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Marek",
            type: .workout(.walking, mode: .manual, value: 200, calories: 200, distance: 3.2, duration: 45 * 60, avgHeartRate: 105, maxHeartRate: 125, items: []),
            timeOffset: 7 * 3600 + 45 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Ziga Porenta",
            type: .text("Power walking! 🚶‍♂️"),
            timeOffset: 8 * 3600,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Nic",
            type: .workout(.coreTraining, mode: .auto, value: 160, calories: 160, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: []),
            timeOffset: 8 * 3600 + 15 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Christopher Schrader",
            type: .text("Crushing it! 💪"),
            timeOffset: 8 * 3600 + 20 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Will Corbett",
            type: .workout(.running, mode: .manual, value: 500, calories: 500, distance: 5.5, duration: 28 * 60, avgHeartRate: 165, maxHeartRate: 185, items: []),
            timeOffset: 8 * 3600 + 30 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Marek",
            type: .text("Marathon training? 🏃‍♂️"),
            timeOffset: 8 * 3600 + 35 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Ziga Porenta",
            type: .workout(.strengthTraining, mode: .auto, value: 300, calories: 300, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: []),
            timeOffset: 8 * 3600 + 45 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Nic",
            type: .text("Heavy lifting! 💪"),
            timeOffset: 9 * 3600,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Christopher Schrader",
            type: .workout(.yoga, mode: .manual, value: 180, calories: 180, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: []),
            timeOffset: 9 * 3600 + 15 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Will Corbett",
            type: .text("Extended session! 🧘‍♂️"),
            timeOffset: 9 * 3600 + 20 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Marek",
            type: .workout(.coreTraining, mode: .auto, value: 220, calories: 220, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: []),
            timeOffset: 9 * 3600 + 30 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Ziga Porenta",
            type: .text("Intense core! 🔥"),
            timeOffset: 9 * 3600 + 35 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Nic",
            type: .workout(.walking, mode: .manual, value: 250, calories: 250, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: []),
            timeOffset: 9 * 3600 + 45 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Christopher Schrader",
            type: .text("Power walking! 🚶‍♂️"),
            timeOffset: 10 * 3600,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Will Corbett",
            type: .workout(.strengthTraining, mode: .auto, value: 350, calories: 350, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: []),
            timeOffset: 10 * 3600 + 15 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Marek",
            type: .text("Beast mode activated! 🦁"),
            timeOffset: 10 * 3600 + 20 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Ziga Porenta",
            type: .workout(.running, mode: .manual, value: 600, calories: 600, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: []),
            timeOffset: 10 * 3600 + 30 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Nic",
            type: .text("Long distance! 🏃‍♂️"),
            timeOffset: 10 * 3600 + 35 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Christopher Schrader",
            type: .workout(.coreTraining, mode: .auto, value: 250, calories: 250, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: []),
            timeOffset: 10 * 3600 + 45 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Will Corbett",
            type: .text("Core strength! 💪"),
            timeOffset: 11 * 3600,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Marek",
            type: .workout(.yoga, mode: .manual, value: 200, calories: 200, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: []),
            timeOffset: 11 * 3600 + 15 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Ziga Porenta",
            type: .text("Extended yoga! 🧘‍♂️"),
            timeOffset: 11 * 3600 + 20 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Nic",
            type: .workout(.strengthTraining, mode: .auto, value: 400, calories: 400, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: []),
            timeOffset: 11 * 3600 + 30 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Christopher Schrader",
            type: .text("Maximum effort! 💯"),
            timeOffset: 11 * 3600 + 35 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Will Corbett",
            type: .workout(.walking, mode: .manual, value: 300, calories: 300, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: []),
            timeOffset: 11 * 3600 + 45 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Marek",
            type: .text("Power walking! 🚶‍♂️"),
            timeOffset: 12 * 3600,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Ziga Porenta",
            type: .workout(.coreTraining, mode: .auto, value: 280, calories: 280, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: []),
            timeOffset: 12 * 3600 + 15 * 60,
            reactions: [
                ReactionConfig(author: "Will Corbett", type: .fire, timeOffset: 2 * 60),
                ReactionConfig(author: "Nic", type: .muscle, timeOffset: 4 * 60),
                ReactionConfig(author: "Marek", type: .like, timeOffset: 6 * 60)
            ],
            comments: [
                CommentConfig(author: "Will Corbett", content: "Core strength! 💪", timeOffset: 3 * 60),
                CommentConfig(author: "Christopher Schrader", content: "Looking strong! 🔥", timeOffset: 8 * 60),
                CommentConfig(author: "Nic", content: "Keep it up! 👏", timeOffset: 12 * 60)
            ],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Nic",
            type: .text("Core power! 💪"),
            timeOffset: 12 * 3600 + 20 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Christopher Schrader",
            type: .workout(.running, mode: .manual, value: 750, calories: 750, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: []),
            timeOffset: 12 * 3600 + 30 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Will Corbett",
            type: .text("Marathon training! 🏃‍♂️"),
            timeOffset: 12 * 3600 + 35 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Marek",
            type: .workout(.strengthTraining, mode: .auto, value: 450, calories: 450, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: []),
            timeOffset: 12 * 3600 + 45 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Ziga Porenta",
            type: .text("Maximum strength! 💪"),
            timeOffset: 13 * 3600,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Nic",
            type: .workout(.yoga, mode: .manual, value: 250, calories: 250, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: []),
            timeOffset: 13 * 3600 + 15 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Christopher Schrader",
            type: .text("Extended session! 🧘‍♂️"),
            timeOffset: 13 * 3600 + 20 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Ziga Porenta",
            type: .workout(.strengthTraining, mode: .auto, value: 550, calories: 550, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: []),
            timeOffset: 13 * 3600 + 30 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Nic",
            type: .text("Maximum power! 💪"),
            timeOffset: 13 * 3600 + 35 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Christopher Schrader",
            type: .workout(.walking, mode: .manual, value: 400, calories: 400, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: []),
            timeOffset: 13 * 3600 + 45 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Will Corbett",
            type: .text("Power walking! 🚶‍♂️"),
            timeOffset: 14 * 3600,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Marek",
            type: .workout(.coreTraining, mode: .auto, value: 400, calories: 400, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: []),
            timeOffset: 14 * 3600 + 15 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Ziga Porenta",
            type: .text("Core strength! 💪"),
            timeOffset: 14 * 3600 + 20 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Nic",
            type: .workout(.running, mode: .manual, value: 1000, calories: 1000, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: []),
            timeOffset: 14 * 3600 + 30 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Christopher Schrader",
            type: .text("Ultra marathon! 🏃‍♂️"),
            timeOffset: 14 * 3600 + 35 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Will Corbett",
            type: .workout(.strengthTraining, mode: .auto, value: 600, calories: 600, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: []),
            timeOffset: 14 * 3600 + 45 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Marek",
            type: .text("Ultimate strength! 💪"),
            timeOffset: 15 * 3600,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Ziga Porenta",
            type: .workout(.yoga, mode: .manual, value: 350, calories: 350, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: []),
            timeOffset: 15 * 3600 + 15 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Nic",
            type: .text("Extended yoga! 🧘‍♂️"),
            timeOffset: 15 * 3600 + 20 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Christopher Schrader",
            type: .workout(.coreTraining, mode: .auto, value: 450, calories: 450, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: []),
            timeOffset: 15 * 3600 + 30 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Will Corbett",
            type: .text("Core power! 💪"),
            timeOffset: 15 * 3600 + 35 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Marek",
            type: .workout(.walking, mode: .manual, value: 450, calories: 450, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: []),
            timeOffset: 15 * 3600 + 45 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Ziga Porenta",
            type: .text("Power walking! 🚶‍♂️"),
            timeOffset: 16 * 3600,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Nic",
            type: .workout(.strengthTraining, mode: .auto, value: 650, calories: 650, distance: nil, duration: 0, avgHeartRate: nil, maxHeartRate: nil, items: []),
            timeOffset: 16 * 3600 + 15 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Christopher Schrader",
            type: .text("Maximum strength! 💪"),
            timeOffset: 16 * 3600 + 20 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        MessageConfig(
            authorName: "Marek",
            type: .text("Ultra distance! 🏃‍♂️"),
            timeOffset: 16 * 3600 + 35 * 60,
            reactions: [],
            comments: [],
            attachedImages: []
        ),
        
        // New Swimming workout by Christopher
        MessageConfig(
            authorName: "Christopher Schrader",
            type: .workout(.swimming, mode: .manual, value: 800, calories: 800, distance: 2.5, duration: 45 * 60, avgHeartRate: 145, maxHeartRate: 175, items: []),
            timeOffset: 17 * 3600,
            reactions: [
                ReactionConfig(author: "Will Corbett", type: .fire, timeOffset: 2 * 60),
                ReactionConfig(author: "Marek", type: .muscle, timeOffset: 5 * 60)
            ],
            comments: [
                CommentConfig(author: "Ziga Porenta", content: "Swimming beast! 🏊‍♂️", timeOffset: 3 * 60)
            ],
            attachedImages: []
        ),
        
        // New Hiking workout by Nic
        MessageConfig(
            authorName: "Nic",
            type: .workout(.hiking, mode: .manual, value: 650, calories: 650, distance: 8.2, duration: 3 * 3600 + 30 * 60, avgHeartRate: 125, maxHeartRate: 155, items: []),
            timeOffset: 17 * 3600 + 30 * 60,
            reactions: [
                ReactionConfig(author: "Christopher Schrader", type: .crown, timeOffset: 2 * 60),
                ReactionConfig(author: "Will Corbett", type: .clap, timeOffset: 4 * 60)
            ],
            comments: [
                CommentConfig(author: "Marek", content: "Mountain conqueror! ⛰️", timeOffset: 5 * 60)
            ],
            attachedImages: []
        )
    ]
} 
