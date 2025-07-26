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
    case workout(WorkoutType, value: Int, calories: Int, mode: WorkoutMode)
}

// MARK: - Message Configuration
struct MessageConfig {
    let authorName: String
    let type: MessageType
    let timeOffset: TimeInterval // offset in seconds from the base time
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
    
    // Helper function to generate random comments for a message
    private static func generateComments(for messageAuthor: String, timestamp: Date) -> [Comment] {
        let commentTemplates = [
            "Great work! 💪",
            "Keep it up! 🔥",
            "Amazing progress! 👏",
            "You're crushing it! 🚀",
            "Inspiring! 👑",
            "Beast mode! 💪",
            "Unstoppable! 🔥",
            "Legend! 👑",
            "Motivation! 💪",
            "Goals! 🚀",
            "Nice try, but I'm still ahead 😏",
            "That's cute, try harder 💅",
            "Oh look, someone's trying to keep up 😂",
            "Is that all you got? 🤔",
            "My grandma lifts more than that 👵",
            "Call me when you're serious 💪",
            "That's adorable 🥺",
            "Keep dreaming, buddy 😴",
            "Maybe next time, champ 🏆",
            "I've seen better form at a yoga class 🧘‍♂️",
            "At least you're trying... I guess 🤷‍♂️",
            "That's what I call a warm-up 🔥",
            "My cat could do better 🐱",
            "Is this a joke? 😅",
            "You call that a workout? 💀",
            "I'm not impressed 😤",
            "Try again when you're ready 🎯",
            "That's the spirit... of giving up 😂",
            "My breakfast had more calories 🍳",
            "Are you even trying? 🤨",
            "That's it? That's your best? 😏"
        ]
        
        let otherAuthors = authors.filter { $0.name != messageAuthor }
        let numComments = Int.random(in: 0...3) // 0-3 comments per post
        
        var comments: [Comment] = []
        for i in 0..<numComments {
            let author = otherAuthors[i % otherAuthors.count]
            let commentTime = timestamp.addingTimeInterval(TimeInterval.random(in: 300...3600)) // 5-60 minutes later
            let comment = Comment(
                author: author.name,
                authorImage: author.imageAsset,
                content: commentTemplates.randomElement() ?? "Great work! 💪",
                timestamp: commentTime
            )
            comments.append(comment)
        }
        
        return comments
    }
    
    // Helper function to generate random reactions for a message
    private static func generateReactions(for messageAuthor: String, timestamp: Date) -> [Reaction] {
        let otherAuthors = authors.filter { $0.name != messageAuthor }
        let numReactions = Int.random(in: 1...5) // 1-5 reactions per post
        
        var reactions: [Reaction] = []
        for i in 0..<numReactions {
            let author = otherAuthors[i % otherAuthors.count]
            let reactionTime = timestamp.addingTimeInterval(TimeInterval.random(in: 60...1800)) // 1-30 minutes later
            let reactionType = ReactionType.allCases.randomElement() ?? .like
            let reaction = Reaction(
                author: author.name,
                authorImage: author.imageAsset,
                type: reactionType,
                timestamp: reactionTime
            )
            reactions.append(reaction)
        }
        
        return reactions
    }
    
    // Helper function to get random attached image
    private static func getRandomAttachedImage() -> String? {
        let imageOptions = ["workout", "steps", "add"] // Using existing assets
        // 30% chance of having an attached image
        return Bool.random() && Bool.random() && Bool.random() ? imageOptions.randomElement() : nil
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
            let workout: Workout?
            
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
            case .workout(let type, let value, let calories, let mode):
                content = nil
                workout = Workout(type: type, value: value, calories: calories, mode: mode)
                
                // Update score for workout
                if let authorIndex = authors.firstIndex(where: { $0.name == config.authorName }) {
                    authors[authorIndex].score += value
                    updateRanks()
                    authorRank = authors[authorIndex].rank
                    authorScore = authors[authorIndex].score
                }
            }
            
            return Message(
                author: config.authorName,
                authorImage: authorImage,
                content: content,
                workout: workout,
                timestamp: timestamp,
                score: (authorRank, authorScore),
                location: getLocationForAuthor(config.authorName),
                attachedImage: getRandomAttachedImage(),
                comments: generateComments(for: config.authorName, timestamp: timestamp),
                reactions: generateReactions(for: config.authorName, timestamp: timestamp)
            )
        }
    }
    
    // Message sequence as displayed in chat
    static let messageSequence: [MessageConfig] = [
        // Initial workout by Ziga
        MessageConfig(
            authorName: "Ziga Porenta",
            type: .workout(.strengthTraining, value: 160, calories: 160, mode: .auto),
            timeOffset: 0
        ),
        
        // Will's reaction
        MessageConfig(
            authorName: "Will Corbett",
            type: .jumboEmoji("😮"),
            timeOffset: 34 * 60 // 34 minutes later
        ),
        
        // Chris's reaction
        MessageConfig(
            authorName: "Christopher Schrader",
            type: .text("damn"),
            timeOffset: 3 * 3600 + 12 * 60 // 3h 12m later
        ),
        
        // Will's comment
        MessageConfig(
            authorName: "Will Corbett",
            type: .text("Somebody better get kamikaze"),
            timeOffset: 3 * 3600 + 47 * 60 // 3h 47m later
        ),
        
        // Will's workout
        MessageConfig(
            authorName: "Will Corbett",
            type: .workout(.strengthTraining, value: 238, calories: 238, mode: .manual),
            timeOffset: 4 * 3600 + 2 * 60 // 4h 2m later
        ),
        
        // Nic's reaction
        MessageConfig(
            authorName: "Nic",
            type: .text("Let's crush it! 💪"),
            timeOffset: 4 * 3600 + 15 * 60 // 4h 15m later
        ),
        
        // Marek's workout
        MessageConfig(
            authorName: "Marek",
            type: .workout(.running, value: 320, calories: 320, mode: .auto),
            timeOffset: 4 * 3600 + 30 * 60 // 4h 30m later
        ),
        
        // Additional static messages to reach 100
        MessageConfig(
            authorName: "Ziga Porenta",
            type: .workout(.coreTraining, value: 150, calories: 150, mode: .auto),
            timeOffset: 5 * 3600
        ),
        
        MessageConfig(
            authorName: "Christopher Schrader",
            type: .text("Nice work! 💪"),
            timeOffset: 5 * 3600 + 15 * 60
        ),
        
        MessageConfig(
            authorName: "Nic",
            type: .workout(.yoga, value: 120, calories: 120, mode: .manual),
            timeOffset: 5 * 3600 + 30 * 60
        ),
        
        MessageConfig(
            authorName: "Will Corbett",
            type: .text("Let's do a group workout! 🏋️‍♂️"),
            timeOffset: 5 * 3600 + 45 * 60
        ),
        
        MessageConfig(
            authorName: "Marek",
            type: .workout(.strengthTraining, value: 250, calories: 250, mode: .auto),
            timeOffset: 6 * 3600
        ),
        
        MessageConfig(
            authorName: "Ziga Porenta",
            type: .text("Beast mode! 🔥"),
            timeOffset: 6 * 3600 + 10 * 60
        ),
        
        MessageConfig(
            authorName: "Nic",
            type: .workout(.running, value: 450, calories: 450, mode: .manual),
            timeOffset: 6 * 3600 + 30 * 60
        ),
        
        MessageConfig(
            authorName: "Christopher Schrader",
            type: .text("New personal best! 🏆"),
            timeOffset: 6 * 3600 + 35 * 60
        ),
        
        MessageConfig(
            authorName: "Will Corbett",
            type: .workout(.coreTraining, value: 180, calories: 180, mode: .auto),
            timeOffset: 6 * 3600 + 45 * 60
        ),
        
        MessageConfig(
            authorName: "Marek",
            type: .text("Keep the momentum! 💫"),
            timeOffset: 7 * 3600
        ),
        
        MessageConfig(
            authorName: "Ziga Porenta",
            type: .workout(.yoga, value: 150, calories: 150, mode: .manual),
            timeOffset: 7 * 3600 + 15 * 60
        ),
        
        MessageConfig(
            authorName: "Nic",
            type: .text("Perfect form! 🧘‍♂️"),
            timeOffset: 7 * 3600 + 20 * 60
        ),
        
        MessageConfig(
            authorName: "Christopher Schrader",
            type: .workout(.strengthTraining, value: 280, calories: 280, mode: .auto),
            timeOffset: 7 * 3600 + 30 * 60
        ),
        
        MessageConfig(
            authorName: "Will Corbett",
            type: .text("Absolute beast mode! 🦁"),
            timeOffset: 7 * 3600 + 35 * 60
        ),
        
        MessageConfig(
            authorName: "Marek",
            type: .workout(.walking, value: 200, calories: 200, mode: .manual),
            timeOffset: 7 * 3600 + 45 * 60
        ),
        
        MessageConfig(
            authorName: "Ziga Porenta",
            type: .text("Power walking! 🚶‍♂️"),
            timeOffset: 8 * 3600
        ),
        
        MessageConfig(
            authorName: "Nic",
            type: .workout(.coreTraining, value: 160, calories: 160, mode: .auto),
            timeOffset: 8 * 3600 + 15 * 60
        ),
        
        MessageConfig(
            authorName: "Christopher Schrader",
            type: .text("Crushing it! 💪"),
            timeOffset: 8 * 3600 + 20 * 60
        ),
        
        MessageConfig(
            authorName: "Will Corbett",
            type: .workout(.running, value: 500, calories: 500, mode: .manual),
            timeOffset: 8 * 3600 + 30 * 60
        ),
        
        MessageConfig(
            authorName: "Marek",
            type: .text("Marathon training? 🏃‍♂️"),
            timeOffset: 8 * 3600 + 35 * 60
        ),
        
        MessageConfig(
            authorName: "Ziga Porenta",
            type: .workout(.strengthTraining, value: 300, calories: 300, mode: .auto),
            timeOffset: 8 * 3600 + 45 * 60
        ),
        
        MessageConfig(
            authorName: "Nic",
            type: .text("Heavy lifting! 💪"),
            timeOffset: 9 * 3600
        ),
        
        MessageConfig(
            authorName: "Christopher Schrader",
            type: .workout(.yoga, value: 180, calories: 180, mode: .manual),
            timeOffset: 9 * 3600 + 15 * 60
        ),
        
        MessageConfig(
            authorName: "Will Corbett",
            type: .text("Extended session! 🧘‍♂️"),
            timeOffset: 9 * 3600 + 20 * 60
        ),
        
        MessageConfig(
            authorName: "Marek",
            type: .workout(.coreTraining, value: 220, calories: 220, mode: .auto),
            timeOffset: 9 * 3600 + 30 * 60
        ),
        
        MessageConfig(
            authorName: "Ziga Porenta",
            type: .text("Intense core! 🔥"),
            timeOffset: 9 * 3600 + 35 * 60
        ),
        
        MessageConfig(
            authorName: "Nic",
            type: .workout(.walking, value: 250, calories: 250, mode: .manual),
            timeOffset: 9 * 3600 + 45 * 60
        ),
        
        MessageConfig(
            authorName: "Christopher Schrader",
            type: .text("Power walking! 🚶‍♂️"),
            timeOffset: 10 * 3600
        ),
        
        MessageConfig(
            authorName: "Will Corbett",
            type: .workout(.strengthTraining, value: 350, calories: 350, mode: .auto),
            timeOffset: 10 * 3600 + 15 * 60
        ),
        
        MessageConfig(
            authorName: "Marek",
            type: .text("Beast mode activated! 🦁"),
            timeOffset: 10 * 3600 + 20 * 60
        ),
        
        MessageConfig(
            authorName: "Ziga Porenta",
            type: .workout(.running, value: 600, calories: 600, mode: .manual),
            timeOffset: 10 * 3600 + 30 * 60
        ),
        
        MessageConfig(
            authorName: "Nic",
            type: .text("Long distance! 🏃‍♂️"),
            timeOffset: 10 * 3600 + 35 * 60
        ),
        
        MessageConfig(
            authorName: "Christopher Schrader",
            type: .workout(.coreTraining, value: 250, calories: 250, mode: .auto),
            timeOffset: 10 * 3600 + 45 * 60
        ),
        
        MessageConfig(
            authorName: "Will Corbett",
            type: .text("Core strength! 💪"),
            timeOffset: 11 * 3600
        ),
        
        MessageConfig(
            authorName: "Marek",
            type: .workout(.yoga, value: 200, calories: 200, mode: .manual),
            timeOffset: 11 * 3600 + 15 * 60
        ),
        
        MessageConfig(
            authorName: "Ziga Porenta",
            type: .text("Extended yoga! 🧘‍♂️"),
            timeOffset: 11 * 3600 + 20 * 60
        ),
        
        MessageConfig(
            authorName: "Nic",
            type: .workout(.strengthTraining, value: 400, calories: 400, mode: .auto),
            timeOffset: 11 * 3600 + 30 * 60
        ),
        
        MessageConfig(
            authorName: "Christopher Schrader",
            type: .text("Maximum effort! 💯"),
            timeOffset: 11 * 3600 + 35 * 60
        ),
        
        MessageConfig(
            authorName: "Will Corbett",
            type: .workout(.walking, value: 300, calories: 300, mode: .manual),
            timeOffset: 11 * 3600 + 45 * 60
        ),
        
        MessageConfig(
            authorName: "Marek",
            type: .text("Power walking! 🚶‍♂️"),
            timeOffset: 12 * 3600
        ),
        
        MessageConfig(
            authorName: "Ziga Porenta",
            type: .workout(.coreTraining, value: 280, calories: 280, mode: .auto),
            timeOffset: 12 * 3600 + 15 * 60
        ),
        
        MessageConfig(
            authorName: "Nic",
            type: .text("Core power! 💪"),
            timeOffset: 12 * 3600 + 20 * 60
        ),
        
        MessageConfig(
            authorName: "Christopher Schrader",
            type: .workout(.running, value: 750, calories: 750, mode: .manual),
            timeOffset: 12 * 3600 + 30 * 60
        ),
        
        MessageConfig(
            authorName: "Will Corbett",
            type: .text("Marathon training! 🏃‍♂️"),
            timeOffset: 12 * 3600 + 35 * 60
        ),
        
        MessageConfig(
            authorName: "Marek",
            type: .workout(.strengthTraining, value: 450, calories: 450, mode: .auto),
            timeOffset: 12 * 3600 + 45 * 60
        ),
        
        MessageConfig(
            authorName: "Ziga Porenta",
            type: .text("Maximum strength! 💪"),
            timeOffset: 13 * 3600
        ),
        
        MessageConfig(
            authorName: "Nic",
            type: .workout(.yoga, value: 250, calories: 250, mode: .manual),
            timeOffset: 13 * 3600 + 15 * 60
        ),
        
        MessageConfig(
            authorName: "Christopher Schrader",
            type: .text("Extended session! 🧘‍♂️"),
            timeOffset: 13 * 3600 + 20 * 60
        ),
        
        MessageConfig(
            authorName: "Ziga Porenta",
            type: .workout(.strengthTraining, value: 550, calories: 550, mode: .auto),
            timeOffset: 13 * 3600 + 30 * 60
        ),
        
        MessageConfig(
            authorName: "Nic",
            type: .text("Maximum power! 💪"),
            timeOffset: 13 * 3600 + 35 * 60
        ),
        
        MessageConfig(
            authorName: "Christopher Schrader",
            type: .workout(.walking, value: 400, calories: 400, mode: .manual),
            timeOffset: 13 * 3600 + 45 * 60
        ),
        
        MessageConfig(
            authorName: "Will Corbett",
            type: .text("Power walking! 🚶‍♂️"),
            timeOffset: 14 * 3600
        ),
        
        MessageConfig(
            authorName: "Marek",
            type: .workout(.coreTraining, value: 400, calories: 400, mode: .auto),
            timeOffset: 14 * 3600 + 15 * 60
        ),
        
        MessageConfig(
            authorName: "Ziga Porenta",
            type: .text("Core strength! 💪"),
            timeOffset: 14 * 3600 + 20 * 60
        ),
        
        MessageConfig(
            authorName: "Nic",
            type: .workout(.running, value: 1000, calories: 1000, mode: .manual),
            timeOffset: 14 * 3600 + 30 * 60
        ),
        
        MessageConfig(
            authorName: "Christopher Schrader",
            type: .text("Ultra marathon! 🏃‍♂️"),
            timeOffset: 14 * 3600 + 35 * 60
        ),
        
        MessageConfig(
            authorName: "Will Corbett",
            type: .workout(.strengthTraining, value: 600, calories: 600, mode: .auto),
            timeOffset: 14 * 3600 + 45 * 60
        ),
        
        MessageConfig(
            authorName: "Marek",
            type: .text("Ultimate strength! 💪"),
            timeOffset: 15 * 3600
        ),
        
        MessageConfig(
            authorName: "Ziga Porenta",
            type: .workout(.yoga, value: 350, calories: 350, mode: .manual),
            timeOffset: 15 * 3600 + 15 * 60
        ),
        
        MessageConfig(
            authorName: "Nic",
            type: .text("Extended yoga! 🧘‍♂️"),
            timeOffset: 15 * 3600 + 20 * 60
        ),
        
        MessageConfig(
            authorName: "Christopher Schrader",
            type: .workout(.coreTraining, value: 450, calories: 450, mode: .auto),
            timeOffset: 15 * 3600 + 30 * 60
        ),
        
        MessageConfig(
            authorName: "Will Corbett",
            type: .text("Core power! 💪"),
            timeOffset: 15 * 3600 + 35 * 60
        ),
        
        MessageConfig(
            authorName: "Marek",
            type: .workout(.walking, value: 450, calories: 450, mode: .manual),
            timeOffset: 15 * 3600 + 45 * 60
        ),
        
        MessageConfig(
            authorName: "Ziga Porenta",
            type: .text("Power walking! 🚶‍♂️"),
            timeOffset: 16 * 3600
        ),
        
        MessageConfig(
            authorName: "Nic",
            type: .workout(.strengthTraining, value: 650, calories: 650, mode: .auto),
            timeOffset: 16 * 3600 + 15 * 60
        ),
        
        MessageConfig(
            authorName: "Christopher Schrader",
            type: .text("Maximum strength! 💪"),
            timeOffset: 16 * 3600 + 20 * 60
        ),
        
        MessageConfig(
            authorName: "Will Corbett",
            type: .workout(.running, value: 1100, calories: 1100, mode: .manual),
            timeOffset: 16 * 3600 + 30 * 60
        ),
        
        MessageConfig(
            authorName: "Marek",
            type: .text("Ultra distance! 🏃‍♂️"),
            timeOffset: 16 * 3600 + 35 * 60
        )
    ]
} 