import SwiftUI

struct SprintTaskRowView: View {
    let task: Task
    let onEdit: () -> Void
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void
    let onToggleCompletion: () -> Void
    let isReorderMode: Bool
    
    var body: some View {
        HStack {
            Button(action: onToggleCompletion) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                    .strikethrough(task.isCompleted)
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .strikethrough(task.isCompleted)
                }
            }
            
            Spacer()
            
            // Weight表示
            Text("\(task.weight.rawValue)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(task.isCompleted ? Color.gray : Color(red: 0.6, green: 0.5, blue: 0.4))
                .cornerRadius(12)
                .opacity(task.isCompleted ? 0.6 : 1.0)
            
            if isReorderMode && !task.isCompleted {
                HStack(spacing: 16) {
                    Button(action: onMoveUp) {
                        Image(systemName: "chevron.up")
                            .foregroundColor(.blue)
                            .font(.title3)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: onMoveDown) {
                        Image(systemName: "chevron.down")
                            .foregroundColor(.blue)
                            .font(.title3)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .opacity(task.isCompleted ? 0.6 : 1.0)
    }
}

#Preview {
    SprintTaskRowView(
        task: Task(title: "サンプルタスク", description: "これはサンプルの説明です"),
        onEdit: {},
        onMoveUp: {},
        onMoveDown: {},
        onToggleCompletion: {},
        isReorderMode: false
    )
    .padding()
}