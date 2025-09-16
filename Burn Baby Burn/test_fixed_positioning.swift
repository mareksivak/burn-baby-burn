// Test fixed positioning calculations
let racetrackLength = 10000
let numberOfSegments = racetrackLength / 500  // 20 segments
let trackHeight = Double(numberOfSegments) * 300  // 300px per segment
let trackHeightWithPadding = trackHeight + 400  // 200px top + 200px bottom
let playerBaseY = 200.0

print("Fixed Track Configuration:")
print("  Racetrack length: \(racetrackLength) points")
print("  Number of segments: \(numberOfSegments)")
print("  Track height: \(trackHeight)px")
print("  Track height with padding: \(trackHeightWithPadding)px")
print("  Player base Y: \(playerBaseY)px")
print()

// Sample player scores
let players = [
    ("Will Corbett", 1338),
    ("Nic", 2020),
    ("Marek", 970),
    ("Christopher Schrader", 1230),
    ("Ziga Porenta", 1010)
]

print("Player Positions (highest scores at top):")
for (name, score) in players {
    let segmentIndex = score / 500
    let yPosition = playerBaseY + (Double(segmentIndex) * 300) + 25
    print("  \(name): score=\(score), segment=\(segmentIndex), Y=\(Int(yPosition))px")
}

print()
print("Debug Markers (every 500 points):")
for i in 0..<numberOfSegments {
    let milestone = i * 500
    let markerY = playerBaseY + (Double(i) * 300)
    print("  \(milestone) points: Y=\(Int(markerY))px")
}
