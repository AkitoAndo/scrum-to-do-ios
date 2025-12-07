import SwiftUI

struct SprintTaskRowView: View {
    let task: Task
    let onEdit: () -> Void
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void
    let onToggleCompletion: () -> Void
    let isReorderMode: Bool

    var body: some View {
        HStack(spacing: 0) {
            // Left color bar - changes based on completion status
            RoundedRectangle(cornerRadius: 2)
                .fill(task.isCompleted ? AppColors.successGradient : AppColors.primaryGradient)
                .frame(width: 4)

            HStack(spacing: AppSpacing.md) {
                // Completion toggle
                Button(action: onToggleCompletion) {
                    ZStack {
                        Circle()
                            .stroke(task.isCompleted ? AppColors.success : AppColors.textTertiary, lineWidth: 2)
                            .frame(width: 26, height: 26)

                        if task.isCompleted {
                            Circle()
                                .fill(AppColors.success)
                                .frame(width: 26, height: 26)

                            Image(systemName: "checkmark")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())

                // Task info
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(task.title)
                        .font(.headline)
                        .foregroundColor(task.isCompleted ? AppColors.textTertiary : AppColors.textPrimary)
                        .strikethrough(task.isCompleted, color: AppColors.textTertiary)
                        .lineLimit(2)

                    if !task.description.isEmpty {
                        Text(task.description)
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                            .lineLimit(2)
                            .opacity(task.isCompleted ? 0.6 : 1)
                    }
                }

                Spacer()

                // Points badge
                PointsBadge(points: task.weight.rawValue, isCompleted: task.isCompleted)

                // Reorder buttons (only show when not completed)
                if isReorderMode && !task.isCompleted {
                    HStack(spacing: AppSpacing.sm) {
                        ReorderButton(icon: "chevron.up", action: onMoveUp)
                        ReorderButton(icon: "chevron.down", action: onMoveDown)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.md)
        }
        .background(AppColors.cardBackground)
        .cornerRadius(AppCornerRadius.md)
        .shadow(color: Color.black.opacity(task.isCompleted ? 0.03 : 0.06), radius: 6, x: 0, y: 2)
        .opacity(task.isCompleted ? 0.8 : 1)
        .contentShape(Rectangle())
    }
}

#Preview {
    VStack(spacing: 12) {
        SprintTaskRowView(
            task: Task(title: "進行中のタスク", description: "これはまだ完了していないタスクです"),
            onEdit: {},
            onMoveUp: {},
            onMoveDown: {},
            onToggleCompletion: {},
            isReorderMode: false
        )

        SprintTaskRowView(
            task: {
                var task = Task(title: "完了したタスク", description: "これは完了したタスクです")
                task.isCompleted = true
                return task
            }(),
            onEdit: {},
            onMoveUp: {},
            onMoveDown: {},
            onToggleCompletion: {},
            isReorderMode: false
        )

        SprintTaskRowView(
            task: Task(title: "並び替えモード", description: "上下ボタンが表示されます"),
            onEdit: {},
            onMoveUp: {},
            onMoveDown: {},
            onToggleCompletion: {},
            isReorderMode: true
        )
    }
    .padding()
    .background(Color(.systemGray6))
}
