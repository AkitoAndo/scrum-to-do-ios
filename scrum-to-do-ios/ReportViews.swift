import SwiftUI

struct ReportListView: View {
    @ObservedObject var viewModel: TaskViewModel
    let showMenu: (() -> Void)?
    @State private var selectedSprint: Sprint? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // カスタムナビゲーションバー
            HStack {
                if let showMenu = showMenu {
                    Button(action: showMenu) {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                }
                
                Spacer()
                
                Text("スプリントレポート")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(red: 0.6, green: 0.5, blue: 0.4))
            
            // レポート一覧
            if viewModel.pastSprints.isEmpty {
                VStack {
                    Spacer()
                    
                    Text("過去のスプリントがありません")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .padding()
                    
                    Text("スプリントを完了すると、ここにレポートが表示されます")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.pastSprints.reversed()) { sprint in
                            Button(action: {
                                selectedSprint = sprint
                            }) {
                                SprintReportRowView(sprint: sprint)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .scaleEffect(selectedSprint?.id == sprint.id ? 0.95 : 1.0)
                            .animation(.easeInOut(duration: 0.1), value: selectedSprint?.id == sprint.id)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemGray6))
            }
        }
        .sheet(item: $selectedSprint) { sprint in
            SprintDetailPopupView(sprint: sprint)
        }
    }
}

struct SprintReportRowView: View {
    let sprint: Sprint
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("スプリント")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(sprint.formattedDateRange)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("完了率")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(Int(sprint.completionRate * 100))%")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("ポイント")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(sprint.completedPoints)/\(sprint.totalPoints)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("平均ベロシティ")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(String(format: "%.1f", sprint.dailyVelocity))/日")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 0.5)
        )
    }
}

struct SprintDetailPopupView: View {
    @Environment(\.dismiss) private var dismiss
    let sprint: Sprint
    @State private var selectedTask: Task? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // スプリント概要
                    VStack(alignment: .leading, spacing: 12) {
                        Text("スプリント概要")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("期間:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text(sprint.formattedDateRange)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Text("合計ポイント:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text("\(sprint.totalPoints)")
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Text("完了ポイント:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text("\(sprint.completedPoints)")
                                    .foregroundColor(.green)
                            }
                            
                            HStack {
                                Text("完了率:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text("\(Int(sprint.completionRate * 100))%")
                                    .foregroundColor(.green)
                            }
                            
                            HStack {
                                Text("平均ベロシティ:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text("\(String(format: "%.1f", sprint.dailyVelocity)) ポイント/日")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // 完了タスク
                    VStack(alignment: .leading, spacing: 12) {
                        Text("完了タスク (\(sprint.completedTasks.count)件)")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        if sprint.completedTasks.isEmpty {
                            Text("完了したタスクはありません")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(sprint.completedTasks) { task in
                                Button(action: {
                                    selectedTask = task
                                }) {
                                    TaskReportRowView(task: task, isCompleted: true)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    // 未完了タスク
                    VStack(alignment: .leading, spacing: 12) {
                        Text("未完了タスク (\(sprint.incompleteTasks.count)件)")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        if sprint.incompleteTasks.isEmpty {
                            Text("未完了のタスクはありません")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(sprint.incompleteTasks) { task in
                                Button(action: {
                                    selectedTask = task
                                }) {
                                    TaskReportRowView(task: task, isCompleted: false)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("スプリント詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(item: $selectedTask) { task in
            TaskDetailPopupView(task: task)
        }
    }
}

struct SprintDetailReportView: View {
    let sprint: Sprint
    
    var body: some View {
        VStack(spacing: 0) {
            // カスタムナビゲーションバー
            HStack {
                Text("スプリント詳細")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(red: 0.6, green: 0.5, blue: 0.4))
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // スプリント概要
                    VStack(alignment: .leading, spacing: 12) {
                        Text("スプリント概要")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("期間:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text(sprint.formattedDateRange)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Text("合計ポイント:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text("\(sprint.totalPoints)")
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Text("完了ポイント:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text("\(sprint.completedPoints)")
                                    .foregroundColor(.green)
                            }
                            
                            HStack {
                                Text("完了率:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text("\(Int(sprint.completionRate * 100))%")
                                    .foregroundColor(.green)
                            }
                            
                            HStack {
                                Text("平均ベロシティ:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text("\(String(format: "%.1f", sprint.dailyVelocity)) ポイント/日")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // 完了タスク
                    VStack(alignment: .leading, spacing: 12) {
                        Text("完了タスク (\(sprint.completedTasks.count)件)")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        if sprint.completedTasks.isEmpty {
                            Text("完了したタスクはありません")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(sprint.completedTasks) { task in
                                TaskReportRowView(task: task, isCompleted: true)
                            }
                        }
                    }
                    
                    // 未完了タスク
                    VStack(alignment: .leading, spacing: 12) {
                        Text("未完了タスク (\(sprint.incompleteTasks.count)件)")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        if sprint.incompleteTasks.isEmpty {
                            Text("未完了のタスクはありません")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(sprint.incompleteTasks) { task in
                                TaskReportRowView(task: task, isCompleted: false)
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct TaskReportRowView: View {
    let task: Task
    let isCompleted: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(task.weight.rawValue)pt")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(isCompleted ? .green : .orange)
                
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isCompleted ? .green : .orange)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct TaskDetailPopupView: View {
    @Environment(\.dismiss) private var dismiss
    let task: Task
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // タスクタイトル
                VStack(alignment: .leading, spacing: 12) {
                    Text("タスク詳細")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(task.title)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // タスク情報
                VStack(alignment: .leading, spacing: 16) {
                    if !task.description.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("説明")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text(task.description)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("ストーリーポイント:")
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(task.weight.rawValue)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(red: 0.6, green: 0.5, blue: 0.4))
                                .cornerRadius(12)
                        }
                        
                        HStack {
                            Text("ステータス:")
                                .fontWeight(.medium)
                            Spacer()
                            Text(task.status.rawValue)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("完了状況:")
                                .fontWeight(.medium)
                            Spacer()
                            HStack {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(task.isCompleted ? .green : .gray)
                                Text(task.isCompleted ? "完了" : "未完了")
                                    .foregroundColor(task.isCompleted ? .green : .gray)
                            }
                        }
                        
                        HStack {
                            Text("作成日:")
                                .fontWeight(.medium)
                            Spacer()
                            Text(task.createdAt, style: .date)
                                .foregroundColor(.secondary)
                        }
                        
                        if task.updatedAt != task.createdAt {
                            HStack {
                                Text("更新日:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text(task.updatedAt, style: .date)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationTitle("タスク詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ReportListView(viewModel: TaskViewModel(), showMenu: nil)
}