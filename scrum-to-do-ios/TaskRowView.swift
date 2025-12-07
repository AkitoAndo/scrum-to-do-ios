import SwiftUI

struct TaskRowView: View {
    let task: Task
    let onEdit: () -> Void
    let onDragHandleTouch: () -> Void
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void
    let isReorderMode: Bool

    var body: some View {
        HStack(spacing: 0) {
            // Left color bar
            RoundedRectangle(cornerRadius: 2)
                .fill(AppColors.primaryGradient)
                .frame(width: 4)

            HStack(spacing: AppSpacing.md) {
                // Task info
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(task.title)
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(2)

                    if !task.description.isEmpty {
                        Text(task.description)
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                            .lineLimit(2)
                    }
                }

                Spacer()

                // Points badge
                PointsBadge(points: task.weight.rawValue)

                // Reorder or edit button
                if isReorderMode {
                    HStack(spacing: AppSpacing.sm) {
                        ReorderButton(icon: "chevron.up", action: onMoveUp)
                        ReorderButton(icon: "chevron.down", action: onMoveDown)
                    }
                } else {
                    Button(action: onEdit) {
                        Image(systemName: "ellipsis")
                            .font(.title3)
                            .foregroundColor(AppColors.textSecondary)
                            .frame(width: 32, height: 32)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.md)
        }
        .background(AppColors.cardBackground)
        .cornerRadius(AppCornerRadius.md)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
        .contentShape(Rectangle())
    }
}

struct ReorderButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.primary)
                .frame(width: 32, height: 32)
                .background(AppColors.primary.opacity(0.1))
                .cornerRadius(AppCornerRadius.sm)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 12) {
        TaskRowView(
            task: Task(title: "サンプルタスク", description: "これはサンプルの説明です"),
            onEdit: {},
            onDragHandleTouch: {},
            onMoveUp: {},
            onMoveDown: {},
            isReorderMode: false
        )

        TaskRowView(
            task: Task(title: "並び替えモード", description: "上下ボタンが表示されます"),
            onEdit: {},
            onDragHandleTouch: {},
            onMoveUp: {},
            onMoveDown: {},
            isReorderMode: true
        )
    }
    .padding()
    .background(Color(.systemGray6))
}
