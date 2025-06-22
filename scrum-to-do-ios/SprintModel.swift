import Foundation

struct Sprint: Identifiable, Codable {
    let id = UUID()
    var startDate: Date
    var endDate: Date
    var completedTasks: [Task]
    var incompleteTasks: [Task]
    var totalPoints: Int
    var completedPoints: Int
    var dailyVelocity: Double
    
    init(startDate: Date, endDate: Date, completedTasks: [Task], incompleteTasks: [Task]) {
        self.startDate = startDate
        self.endDate = endDate
        self.completedTasks = completedTasks
        self.incompleteTasks = incompleteTasks
        
        let allTasks = completedTasks + incompleteTasks
        self.totalPoints = allTasks.reduce(0) { $0 + $1.weight.rawValue }
        self.completedPoints = completedTasks.reduce(0) { $0 + $1.weight.rawValue }
        
        let dayCount = max(1, Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 1)
        self.dailyVelocity = Double(completedPoints) / Double(dayCount)
    }
    
    var formattedDateRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
    
    var completionRate: Double {
        guard totalPoints > 0 else { return 0.0 }
        return Double(completedPoints) / Double(totalPoints)
    }
}