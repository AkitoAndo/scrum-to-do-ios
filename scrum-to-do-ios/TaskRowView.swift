import SwiftUI

struct TaskRowView: View {
    let task: Task
    let onEdit: () -> Void
    let onDragHandleTouch: () -> Void
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void
    let isReorderMode: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
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
                .background(Color(red: 0.6, green: 0.5, blue: 0.4))
                .cornerRadius(12)
            
            HStack(spacing: 16) {
                if isReorderMode {
                    HStack(spacing: 8) {
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
                } else {
                    Button(action: onEdit) {
                        VStack(spacing: 2) {
                            ForEach(0..<3) { _ in
                                Rectangle()
                                    .fill(Color.gray)
                                    .frame(width: 20, height: 2)
                                    .cornerRadius(1)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
}()

#Preview {
    TaskRowView(
        task: Task(title: "サンプルタスク", description: "これはサンプルの説明です"),
        onEdit: {},
        onDragHandleTouch: {},
        onMoveUp: {},
        onMoveDown: {},
        isReorderMode: false
    )
    .padding()
}