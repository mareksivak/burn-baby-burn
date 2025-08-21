import SwiftUI

struct WorkoutComparisonView: View {
    let currentWorkout: Workout
    let currentAuthor: String
    @State private var selectedView: ComparisonViewType = .myWorkouts
    @State private var currentPage: Int = 0
    private let workoutsPerPage: Int = 6
    
    enum ComparisonViewType {
        case myWorkouts
        case allWorkouts
    }
    
    // Get all workouts from messages
    private var allWorkouts: [WorkoutWithContext] {
        let messages = AppConfig.generateMessages()
        let workoutContexts = messages.compactMap { (message: Message) -> WorkoutWithContext? in
            guard let workout = message.workout else { return nil }
            return WorkoutWithContext(
                workout: workout,
                author: message.author,
                authorImage: message.authorImage,
                timestamp: message.timestamp,
                rank: 0 // Will be calculated
            )
        }
        
        return workoutContexts
            .sorted { (first: WorkoutWithContext, second: WorkoutWithContext) in
                first.workout.calories > second.workout.calories
            }
            .enumerated()
            .map { (index: Int, workoutContext: WorkoutWithContext) in
                var updatedWorkout = workoutContext
                updatedWorkout.rank = index + 1
                return updatedWorkout
            }
    }
    
    // Get current user's workouts
    private var myWorkouts: [WorkoutWithContext] {
        allWorkouts.filter { $0.author == currentAuthor }
    }
    
    // Get current view workouts
    private var currentViewWorkouts: [WorkoutWithContext] {
        switch selectedView {
        case .myWorkouts:
            return myWorkouts
        case .allWorkouts:
            return allWorkouts
        }
    }
    
    // Get paginated workouts (now synchronized with chart)
    private var paginatedWorkouts: [WorkoutWithContext] {
        let startIndex = currentPage * workoutsPerPage
        let endIndex = min(startIndex + workoutsPerPage, currentViewWorkouts.count)
        return Array(currentViewWorkouts[startIndex..<endIndex])
    }
    
    // Get total pages
    private var totalPages: Int {
        Int(ceil(Double(currentViewWorkouts.count) / Double(workoutsPerPage)))
    }
    
    // Find current workout rank
    private var currentWorkoutRank: Int {
        if let index = currentViewWorkouts.firstIndex(where: { $0.workout.id == currentWorkout.id }) {
            return currentViewWorkouts[index].rank
        }
        return 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Text("WORKOUT COMPARISON")
                .font(.custom("VT323-Regular", size: 18))
                .foregroundColor(Colors.c0_500)
                .padding(.horizontal)
            
            // Toggle Switch
            HStack(spacing: 0) {
                // Player Workouts Button
                Button(action: {
                    selectedView = .myWorkouts
                    currentPage = 0
                }) {
                    Text("PLAYER")
                        .font(.custom("VT323-Regular", size: 14))
                        .foregroundColor(selectedView == .myWorkouts ? Colors.c0_050 : Colors.c0_500)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(selectedView == .myWorkouts ? Color(red: 0.6, green: 0.39, blue: 0.39) : Color.clear)
                        .cornerRadius(8)
                }
                
                // Everyone Workouts Button
                Button(action: {
                    selectedView = .allWorkouts
                    currentPage = 0
                }) {
                    Text("EVERYONE")
                        .font(.custom("VT323-Regular", size: 14))
                        .foregroundColor(selectedView == .allWorkouts ? Colors.c0_050 : Colors.c0_500)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(selectedView == .allWorkouts ? Color(red: 0.6, green: 0.39, blue: 0.39) : Color.clear)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            // Chart Area
            WorkoutChartView(
                workouts: currentViewWorkouts,
                currentWorkoutId: currentWorkout.id,
                currentAuthor: currentAuthor,
                currentChartPage: $currentPage
            )
            .padding(.horizontal)
            
            // Add spacing between chart and workout list
            Spacer()
                .frame(height: 16)
            
            // Workout List
            if currentViewWorkouts.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "figure.run")
                        .font(.system(size: 48))
                        .foregroundColor(Colors.c0_050.opacity(0.6))
                    Text("No workouts found")
                        .font(.custom("VT323-Regular", size: 18))
                        .foregroundColor(Colors.c0_050.opacity(0.8))
                    Text("Try switching between Player and Everyone")
                        .font(.custom("VT323-Regular", size: 14))
                        .foregroundColor(Colors.c0_050.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(40)
                .background(Color(red: 0.6, green: 0.39, blue: 0.39))
                .cornerRadius(12)
                .padding(.horizontal)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(paginatedWorkouts) { workoutContext in
                        WorkoutComparisonCard(
                            workoutContext: workoutContext,
                            isCurrentWorkout: workoutContext.workout.id == currentWorkout.id
                        )
                    }
                }
                .padding(.horizontal)
            }
            
                        // Pagination Controls
            if totalPages > 1 {
                HStack(spacing: 12) {
                    Button(action: {
                        if currentPage > 0 {
                            currentPage -= 1
                        }
                    }) {
                        Text("Previous")
                            .font(.custom("VT323-Regular", size: 14))
                            .foregroundColor(currentPage > 0 ? Colors.c0_050 : Colors.c0_500)
                    }
                    .disabled(currentPage <= 0)
                    
                    ForEach(0..<totalPages, id: \.self) { page in
                        Button(action: {
                            currentPage = page
                        }) {
                            Text("\(page + 1)")
                                .font(.custom("VT323-Regular", size: 14))
                                .foregroundColor(page == currentPage ? Colors.c0_050 : Colors.c0_500)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(page == currentPage ? Color(red: 0.6, green: 0.39, blue: 0.39) : Color.clear)
                                .cornerRadius(4)
                        }
                    }
                    
                    Button(action: {
                        if currentPage < totalPages - 1 {
                            currentPage += 1
                        }
                    }) {
                        Text("Next")
                            .font(.custom("VT323-Regular", size: 14))
                            .foregroundColor(currentPage < totalPages - 1 ? Colors.c0_050 : Colors.c0_500)
                    }
                    .disabled(currentPage >= totalPages - 1)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            } else if totalPages == 1 {
                // Single page indicator
                HStack {
                    Spacer()
                    Text("Page 1 of 1")
                        .font(.custom("VT323-Regular", size: 12))
                        .foregroundColor(Colors.c0_050.opacity(0.6))
                    Spacer()
                }
                .padding(.horizontal)
            }
            
            // Achievement Message
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.2))
                Text("Best effort EVER!")
                    .font(.custom("VT323-Regular", size: 16))
                    .foregroundColor(Color(red: 0.8, green: 0.4, blue: 0.2))
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .onAppear {
            // Reset chart animation when main view appears (user returns to view)
            // This will ensure the chart animates from 0 to final values
        }
    }
}

// Workout with context data
struct WorkoutWithContext: Identifiable {
    let id = UUID()
    let workout: Workout
    let author: String
    let authorImage: String
    let timestamp: Date
    var rank: Int
}

// Workout Chart View
struct WorkoutChartView: View {
    let workouts: [WorkoutWithContext]
    let currentWorkoutId: UUID
    let currentAuthor: String
    @Binding var currentChartPage: Int
    private let workoutsPerChartPage: Int = 6
    
    // Private helper view for empty state
    private struct EmptyChartStateView: View {
        var body: some View {
            VStack(spacing: 12) {
                Image(systemName: "figure.run")
                    .font(.system(size: 48))
                    .foregroundColor(Colors.c0_050.opacity(0.6))
                Text("No workouts yet!")
                    .font(.custom("VT323-Regular", size: 18))
                    .foregroundColor(Colors.c0_050.opacity(0.8))
                Text("Complete your first workout to see it here!")
                    .font(.custom("VT323-Regular", size: 14))
                    .foregroundColor(Colors.c0_050.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .frame(height: 200) // Increased height to accommodate lower pagination dots
        }
    }
    
    // Private helper view for chart content
    private struct ChartContentView: View {
        let workouts: [WorkoutWithContext]
        let currentWorkoutId: UUID
        let currentChartPage: Int
        let totalChartPages: Int
        let maxCalories: Int
        let minCalories: Int
        let safeCalorieRange: Int
        @State private var animateChart: Bool = false
        
        var body: some View {
            ZStack(alignment: .bottomLeading) {
                // Y-axis labels
                VStack(alignment: .trailing, spacing: 0) {
                    ForEach((0...4).reversed(), id: \.self) { i in
                        let calories = minCalories + safeCalorieRange * i / 4
                        Text("\(calories)cal")
                            .font(.custom("VT323-Regular", size: 14))
                            .foregroundColor(Colors.c0_050.opacity(0.8))
                            .frame(height: 30)
                    }
                }
                .padding(.trailing, 12)
                
                // Bars
                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(workouts) { workoutContext in
                        VStack(spacing: 6) {
                            // Bar
                            let height = CGFloat(workoutContext.workout.calories - minCalories) / CGFloat(safeCalorieRange) * 120
                            let isCurrentWorkout = workoutContext.workout.id == currentWorkoutId
                            
                            VStack(spacing: 0) {
                                // Circular top - animated
                                Circle()
                                    .fill(isCurrentWorkout ? Color.yellow : Colors.c0_050.opacity(0.9))
                                    .frame(width: 16, height: 16)
                                    .shadow(color: isCurrentWorkout ? Color.yellow.opacity(0.5) : Colors.c0_050.opacity(0.3), radius: 2)
                                    .offset(y: animateChart ? 0 : 120) // Animate from bottom
                                    .animation(.easeOut(duration: 0.6), value: animateChart)
                                
                                // Bar line - animated
                                Rectangle()
                                    .fill(isCurrentWorkout ? Color.yellow.opacity(0.7) : Colors.c0_050.opacity(0.4))
                                    .frame(width: 2, height: max(1, height))
                                    .cornerRadius(1)
                                    .scaleEffect(y: animateChart ? 1 : 0, anchor: .bottom) // Animate from bottom
                                    .animation(.easeOut(duration: 0.5), value: animateChart)
                            }
                            
                            // Rank number
                            Text("\(workoutContext.rank)")
                                .font(.custom("VT323-Regular", size: 12))
                                .foregroundColor(Colors.c0_050.opacity(0.8))
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding(.leading, 80)
                
                // Chart pagination indicator - positioned much lower to prevent occlusion
                if totalChartPages > 1 {
                    Spacer()
                        .frame(height: 20)
                    
                    HStack(spacing: 8) {
                        Spacer()
                        ForEach(0..<totalChartPages, id: \.self) { page in
                            Circle()
                                .fill(page == currentChartPage ? Colors.c0_050 : Colors.c0_050.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                        Spacer()
                    }
                    .padding(.bottom, 12)
                }
            }
            .frame(height: 200) // Increased height to accommodate lower pagination dots
            .onAppear {
                // Trigger chart animation when view appears
                animateChart = true
            }
            .onChange(of: currentChartPage) { _ in
                // Reset and re-trigger animation when page changes
                animateChart = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animateChart = true
                }
            }
        }
    }
    
    private var maxCalories: Int {
        workouts.map { $0.workout.calories }.max() ?? 500
    }
    
    private var minCalories: Int {
        workouts.map { $0.workout.calories }.min() ?? 0
    }
    
    // Prevent division by zero in chart calculations
    private var safeCalorieRange: Int {
        max(1, maxCalories - minCalories)
    }
    
    // Get paginated workouts for chart
    private var paginatedChartWorkouts: [WorkoutWithContext] {
        let startIndex = currentChartPage * workoutsPerChartPage
        let endIndex = min(startIndex + workoutsPerChartPage, workouts.count)
        return Array(workouts[startIndex..<endIndex])
    }
    
    // Get total chart pages
    private var totalChartPages: Int {
        Int(ceil(Double(workouts.count) / Double(workoutsPerChartPage)))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Chart Area
            if workouts.isEmpty {
                EmptyChartStateView()
            } else {
                ChartContentView(
                    workouts: paginatedChartWorkouts,
                    currentWorkoutId: currentWorkoutId,
                    currentChartPage: currentChartPage,
                    totalChartPages: totalChartPages,
                    maxCalories: maxCalories,
                    minCalories: minCalories,
                    safeCalorieRange: safeCalorieRange
                )
            }
        }
        .padding(20)
        .padding(.bottom, 8) // Add extra bottom padding to prevent occlusion
        .background(Color(red: 0.6, green: 0.39, blue: 0.39))
        .cornerRadius(12)
        .gesture(
            DragGesture()
                .onEnded { value in
                    let threshold: CGFloat = 50
                    if value.translation.width > threshold && currentChartPage > 0 {
                        // Swipe right - go to previous page
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentChartPage -= 1
                        }
                    } else if value.translation.width < -threshold && currentChartPage < totalChartPages - 1 {
                        // Swipe left - go to next page
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentChartPage += 1
                        }
                    }
                }
        )
    }
}

// Workout Comparison Card
struct WorkoutComparisonCard: View {
    let workoutContext: WorkoutWithContext
    let isCurrentWorkout: Bool
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Main workout info
            HStack {
                // Rank
                Text("#\(workoutContext.rank)")
                    .font(.custom("PressStart2P-Regular", size: 20))
                    .foregroundColor(Colors.c0_050)
                
                VStack(alignment: .leading, spacing: 2) {
                    // Author and Activity
                    HStack(spacing: 8) {
                        Text(workoutContext.author)
                            .font(.custom("VT323-Regular", size: 16))
                            .foregroundColor(Colors.c0_050)
                        
                        Image(systemName: getWorkoutIcon(for: workoutContext.workout.type))
                            .font(.system(size: 16))
                            .foregroundColor(Colors.c0_050)
                        
                        Text(workoutContext.workout.type.rawValue.replacingOccurrences(of: "\n", with: " "))
                            .font(.custom("VT323-Regular", size: 14))
                            .foregroundColor(Colors.c0_050.opacity(0.8))
                    }
                    
                    // Calories
                    Text("\(workoutContext.workout.calories) cal")
                        .font(.custom("VT323-Regular", size: 18))
                        .foregroundColor(Colors.c0_050)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                // Current workout indicator
                if isCurrentWorkout {
                    Text("YOU")
                        .font(.custom("VT323-Regular", size: 12))
                        .foregroundColor(Color.yellow)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.yellow.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            
            // Expandable details
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                        .background(Colors.c0_500.opacity(0.3))
                    
                    // Workout details
                    if let distance = workoutContext.workout.distance {
                        HStack {
                            Text("Distance:")
                                .font(.custom("VT323-Regular", size: 14))
                                .foregroundColor(Colors.c0_050.opacity(0.8))
                            Text("\(String(format: "%.1f km", distance))")
                                .font(.custom("VT323-Regular", size: 14))
                                .foregroundColor(Colors.c0_050)
                            Spacer()
                        }
                    }
                    
                    if workoutContext.workout.duration > 0 {
                        HStack {
                            Text("Duration:")
                                .font(.custom("VT323-Regular", size: 14))
                                .foregroundColor(Colors.c0_050.opacity(0.8))
                            Text(formatDuration(workoutContext.workout.duration))
                                .font(.custom("VT323-Regular", size: 14))
                                .foregroundColor(Colors.c0_050)
                            Spacer()
                        }
                    }
                    
                    if let avgHR = workoutContext.workout.avgHeartRate {
                        HStack {
                            Text("Heart Rate:")
                                .font(.custom("VT323-Regular", size: 14))
                                .foregroundColor(Colors.c0_050.opacity(0.8))
                            Text("\(avgHR) bpm")
                                .font(.custom("VT323-Regular", size: 14))
                                .foregroundColor(Colors.c0_050)
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color(red: 0.6, green: 0.39, blue: 0.39))
        .cornerRadius(8)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded.toggle()
            }
        }
    }
    
    private func getWorkoutIcon(for workoutType: WorkoutType) -> String {
        switch workoutType {
        case .strengthTraining:
            return "figure.strengthtraining.traditional"
        case .running:
            return "figure.run"
        case .walking:
            return "figure.walk"
        case .swimming:
            return "figure.pool.swim"
        case .hiking:
            return "figure.hiking"
        case .coreTraining:
            return "figure.core.training"
        case .yoga:
            return "figure.yoga"
        }
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds) % 3600 / 60
        let secs = Int(seconds) % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%02d:%02d", minutes, secs)
        }
    }
}

#Preview {
    WorkoutComparisonView(
        currentWorkout: Workout(
            type: .running,
            value: 1100,
            calories: 1100,
            mode: .manual,
            distance: 10.5,
            duration: 52 * 60,
            avgHeartRate: 165,
            maxHeartRate: 185
        ),
        currentAuthor: "Will Corbett"
    )
    .padding()
    .background(Color(red: 0.13, green: 0.08, blue: 0.08))
}
