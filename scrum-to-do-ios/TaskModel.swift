import Foundation

struct Task: Identifiable, Codable, Equatable {
    let id = UUID()
    var title: String
    var description: String
    var status: TaskStatus
    var weight: FibonacciWeight = .three
    var isCompleted: Bool = false
    var createdAt: Date
    var updatedAt: Date
    
    init(title: String, description: String = "", status: TaskStatus = .backlog, weight: FibonacciWeight = .three, isCompleted: Bool = false) {
        self.title = title
        self.description = description
        self.status = status
        self.weight = weight
        self.isCompleted = isCompleted
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    mutating func updateStatus(_ newStatus: TaskStatus) {
        self.status = newStatus
        self.updatedAt = Date()
    }
    
    mutating func toggleCompletion() {
        self.isCompleted.toggle()
        self.updatedAt = Date()
    }
}


enum TaskStatus: String, CaseIterable, Codable {
    case backlog = "バックログ"
    case todo = "TODO"
    case inProgress = "進行中"
    case done = "完了"
}

enum FibonacciWeight: Int, CaseIterable, Codable {
    case one = 1
    case two = 2
    case three = 3
    case five = 5
    case eight = 8
    case thirteen = 13
    case twentyOne = 21
    
    var displayName: String {
        return "\(self.rawValue)"
    }
}