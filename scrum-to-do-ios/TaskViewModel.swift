import Foundation
import SwiftUI

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var sprintTasks: [Task] = []
    @Published var planningSprintTasks: [Task] = []
    @Published var isSprintActive = false
    @Published var pastSprints: [Sprint] = []
    @Published var currentSprintStartDate: Date?
    
    init() {
        loadSampleData()
    }
    
    func addTask(title: String, description: String = "", weight: FibonacciWeight = .three) {
        let newTask = Task(title: title, description: description, weight: weight)
        tasks.append(newTask)
        saveTasks()
    }
    
    func updateTask(_ task: Task, title: String, description: String, weight: FibonacciWeight) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].title = title
            tasks[index].description = description
            tasks[index].weight = weight
            tasks[index].updatedAt = Date()
            saveTasks()
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    func deleteTask(at indexSet: IndexSet) {
        tasks.remove(atOffsets: indexSet)
        saveTasks()
    }
    
    func moveTask(from source: IndexSet, to destination: Int) {
        tasks.move(fromOffsets: source, toOffset: destination)
        saveTasks()
    }
    
    func moveTaskUp(_ task: Task) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if let index = tasks.firstIndex(where: { $0.id == task.id }), index > 0 {
                tasks.move(fromOffsets: IndexSet(integer: index), toOffset: index - 1)
                saveTasks()
            }
        }
    }
    
    func moveTaskDown(_ task: Task) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if let index = tasks.firstIndex(where: { $0.id == task.id }), index < tasks.count - 1 {
                tasks.move(fromOffsets: IndexSet(integer: index), toOffset: index + 2)
                saveTasks()
            }
        }
    }
    
    
    func updateTaskStatus(_ task: Task, status: TaskStatus) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].updateStatus(status)
            saveTasks()
        }
    }
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: "SavedTasks")
        }
    }
    
    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: "SavedTasks"),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        }
    }
    
    func moveTaskToPlanningSprint(_ task: Task) {
        if !planningSprintTasks.contains(where: { $0.id == task.id }) {
            planningSprintTasks.append(task)
        }
    }
    
    func moveTaskFromPlanningSprint(_ task: Task) {
        planningSprintTasks.removeAll { $0.id == task.id }
    }
    
    func clearPlanningSprint() {
        planningSprintTasks.removeAll()
    }
    
    func startSprint() {
        // プランニング中のタスクを正式なスプリントタスクに移動
        for task in planningSprintTasks {
            if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                let taskToMove = tasks.remove(at: index)
                sprintTasks.append(taskToMove)
            }
        }
        
        planningSprintTasks.removeAll()
        isSprintActive = true
        currentSprintStartDate = Date()
        saveTasks()
    }
    
    func endSprint() {
        guard let startDate = currentSprintStartDate else { return }
        
        // スプリントレポートを作成
        let completedTasks = sprintTasks.filter { $0.isCompleted }
        let incompleteTasks = sprintTasks.filter { !$0.isCompleted }
        
        let sprint = Sprint(
            startDate: startDate,
            endDate: Date(),
            completedTasks: completedTasks,
            incompleteTasks: incompleteTasks
        )
        
        pastSprints.append(sprint)
        
        // 未完了のタスクをプロダクトバックログの先頭に移動
        for task in incompleteTasks.reversed() {
            var resetTask = task
            resetTask.isCompleted = false
            tasks.insert(resetTask, at: 0)
        }
        
        isSprintActive = false
        sprintTasks.removeAll()
        currentSprintStartDate = nil
        saveTasks()
    }
    
    func moveSprintTaskUp(_ task: Task) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if let index = sprintTasks.firstIndex(where: { $0.id == task.id }), index > 0 {
                sprintTasks.move(fromOffsets: IndexSet(integer: index), toOffset: index - 1)
                saveTasks()
            }
        }
    }
    
    func moveSprintTaskDown(_ task: Task) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if let index = sprintTasks.firstIndex(where: { $0.id == task.id }), index < sprintTasks.count - 1 {
                sprintTasks.move(fromOffsets: IndexSet(integer: index), toOffset: index + 2)
                saveTasks()
            }
        }
    }
    
    func toggleSprintTaskCompletion(_ task: Task) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if let index = sprintTasks.firstIndex(where: { $0.id == task.id }) {
                sprintTasks[index].toggleCompletion()
                
                let toggledTask = sprintTasks.remove(at: index)
                if toggledTask.isCompleted {
                    // 完了済みタスクを一番下に移動
                    sprintTasks.append(toggledTask)
                } else {
                    // 未完了に戻すタスクを一番上に移動
                    sprintTasks.insert(toggledTask, at: 0)
                }
                saveTasks()
            }
        }
    }
    
    var incompleteSprintTasks: [Task] {
        sprintTasks.filter { !$0.isCompleted }
    }
    
    var completedSprintTasks: [Task] {
        sprintTasks.filter { $0.isCompleted }
    }
    
    var pastThreeSprintVelocities: [Double] {
        let recentSprints = Array(pastSprints.suffix(3))
        return recentSprints.map { $0.dailyVelocity }
    }
    
    var averageVelocity: Double {
        let velocities = pastThreeSprintVelocities
        return velocities.isEmpty ? 0.0 : velocities.reduce(0, +) / Double(velocities.count)
    }
    
    var planningSprintTotalPoints: Int {
        planningSprintTasks.reduce(0) { $0 + $1.weight.rawValue }
    }
    
    private func loadSampleData() {
        tasks = [
            Task(title: "ユーザー認証機能", description: "ログイン・サインアップ機能の実装", weight: .eight),
            Task(title: "データベース設計", description: "ユーザーとタスクのテーブル設計", weight: .five),
            Task(title: "API設計", description: "RESTful APIの設計と実装", weight: .thirteen),
            Task(title: "UI/UXデザイン", description: "アプリケーションの画面設計", weight: .five),
            Task(title: "テスト実装", description: "単体テストと統合テストの実装", weight: .three)
        ]
        
        // サンプルの過去スプリントデータを追加
        let calendar = Calendar.current
        let now = Date()
        
        // 3つ前のスプリント
        if let sprint3Start = calendar.date(byAdding: .day, value: -42, to: now),
           let sprint3End = calendar.date(byAdding: .day, value: -28, to: now) {
            let completedTasks = [
                Task(title: "ログイン画面", description: "ユーザーログイン機能", weight: .five, isCompleted: true),
                Task(title: "バックエンドAPI", description: "認証API実装", weight: .eight, isCompleted: true)
            ]
            let incompleteTasks = [
                Task(title: "エラーハンドリング", description: "エラー処理実装", weight: .three, isCompleted: false)
            ]
            pastSprints.append(Sprint(startDate: sprint3Start, endDate: sprint3End, completedTasks: completedTasks, incompleteTasks: incompleteTasks))
        }
        
        // 2つ前のスプリント
        if let sprint2Start = calendar.date(byAdding: .day, value: -28, to: now),
           let sprint2End = calendar.date(byAdding: .day, value: -14, to: now) {
            let completedTasks = [
                Task(title: "ユーザー管理", description: "ユーザー情報管理", weight: .thirteen, isCompleted: true),
                Task(title: "プロフィール画面", description: "プロフィール表示", weight: .five, isCompleted: true)
            ]
            let incompleteTasks = [
                Task(title: "設定画面", description: "アプリ設定", weight: .two, isCompleted: false)
            ]
            pastSprints.append(Sprint(startDate: sprint2Start, endDate: sprint2End, completedTasks: completedTasks, incompleteTasks: incompleteTasks))
        }
        
        // 1つ前のスプリント
        if let sprint1Start = calendar.date(byAdding: .day, value: -14, to: now),
           let sprint1End = calendar.date(byAdding: .day, value: 0, to: now) {
            let completedTasks = [
                Task(title: "データ同期", description: "クラウド同期機能", weight: .eight, isCompleted: true),
                Task(title: "通知機能", description: "プッシュ通知", weight: .five, isCompleted: true),
                Task(title: "UI改善", description: "デザイン改善", weight: .three, isCompleted: true)
            ]
            pastSprints.append(Sprint(startDate: sprint1Start, endDate: sprint1End, completedTasks: completedTasks, incompleteTasks: []))
        }
    }
}