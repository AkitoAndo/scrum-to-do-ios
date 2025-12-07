import SwiftUI

struct ReportListView: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var selectedSprint: Sprint? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.secondaryBackground
                    .ignoresSafeArea()

                if viewModel.pastSprints.isEmpty {
                    EmptyStateView(
                        icon: "chart.bar.xaxis",
                        title: "レポートがありません",
                        description: "スプリントを完了すると\nここにレポートが表示されます"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: AppSpacing.md) {
                            // Summary card
                            summaryCard

                            // Velocity chart
                            VelocityChart(
                                velocities: viewModel.pastThreeSprintVelocities,
                                average: viewModel.averageVelocity
                            )

                            // Sprint list header
                            HStack {
                                Text("スプリント履歴")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textPrimary)
                                Spacer()
                                Text("\(viewModel.pastSprints.count)件")
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .padding(.top, AppSpacing.md)

                            // Sprint list
                            ForEach(viewModel.pastSprints.reversed()) { sprint in
                                SprintReportCard(sprint: sprint)
                                    .onTapGesture {
                                        selectedSprint = sprint
                                    }
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.vertical, AppSpacing.md)
                    }
                }
            }
            .navigationTitle("レポート")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedSprint) { sprint in
                SprintDetailView(sprint: sprint)
            }
        }
    }

    private var summaryCard: some View {
        HStack(spacing: AppSpacing.lg) {
            StatCard(
                title: "完了スプリント",
                value: "\(viewModel.pastSprints.count)",
                icon: "checkmark.circle.fill",
                color: AppColors.success
            )

            let totalCompleted = viewModel.pastSprints.reduce(0) { $0 + $1.completedPoints }
            StatCard(
                title: "総完了ポイント",
                value: "\(totalCompleted)",
                subtitle: "pt",
                icon: "star.fill",
                color: AppColors.accent
            )
        }
    }
}

struct SprintReportCard: View {
    let sprint: Sprint

    var body: some View {
        HStack(spacing: AppSpacing.lg) {
            // Progress circle
            CircularProgressView(
                progress: sprint.completionRate,
                size: 60,
                lineWidth: 6
            )

            // Sprint info
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack {
                    Text("スプリント")
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppColors.textTertiary)
                }

                Text(sprint.formattedDateRange)
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)

                HStack(spacing: AppSpacing.lg) {
                    Label("\(sprint.completedPoints)/\(sprint.totalPoints) pt", systemImage: "checkmark.circle")
                        .font(.caption)
                        .foregroundColor(AppColors.success)

                    Label(String(format: "%.1f pt/日", sprint.dailyVelocity), systemImage: "speedometer")
                        .font(.caption)
                        .foregroundColor(AppColors.primary)
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.cardBackground)
        .cornerRadius(AppCornerRadius.md)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

struct SprintDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let sprint: Sprint
    @State private var selectedTask: Task? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.secondaryBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // Summary card
                        sprintSummaryCard

                        // Completed tasks
                        taskSection(
                            title: "完了タスク",
                            tasks: sprint.completedTasks,
                            isCompleted: true
                        )

                        // Incomplete tasks
                        if !sprint.incompleteTasks.isEmpty {
                            taskSection(
                                title: "未完了タスク",
                                tasks: sprint.incompleteTasks,
                                isCompleted: false
                            )
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.md)
                }
            }
            .navigationTitle("スプリント詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primary)
                }
            }
            .sheet(item: $selectedTask) { task in
                TaskDetailView(task: task)
            }
        }
    }

    private var sprintSummaryCard: some View {
        VStack(spacing: AppSpacing.lg) {
            HStack(spacing: AppSpacing.xl) {
                CircularProgressView(
                    progress: sprint.completionRate,
                    size: 100,
                    lineWidth: 10
                )

                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("期間")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                        Text(sprint.formattedDateRange)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.textPrimary)
                    }

                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("ベロシティ")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                        Text(String(format: "%.1f pt/日", sprint.dailyVelocity))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.primary)
                    }
                }

                Spacer()
            }

            HStack(spacing: AppSpacing.md) {
                StatCard(
                    title: "完了",
                    value: "\(sprint.completedPoints)",
                    subtitle: "pt",
                    icon: "checkmark.circle.fill",
                    color: AppColors.success
                )
                StatCard(
                    title: "合計",
                    value: "\(sprint.totalPoints)",
                    subtitle: "pt",
                    icon: "chart.bar.fill",
                    color: AppColors.primary
                )
                StatCard(
                    title: "タスク",
                    value: "\(sprint.completedTasks.count + sprint.incompleteTasks.count)",
                    subtitle: "件",
                    icon: "list.bullet",
                    color: AppColors.accent
                )
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.cardBackground)
        .cornerRadius(AppCornerRadius.lg)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    private func taskSection(title: String, tasks: [Task], isCompleted: Bool) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Text("\(tasks.count)件")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
            }

            if tasks.isEmpty {
                Text(isCompleted ? "完了したタスクはありません" : "未完了のタスクはありません")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(AppSpacing.xl)
            } else {
                ForEach(tasks) { task in
                    ReportTaskRow(task: task, isCompleted: isCompleted)
                        .onTapGesture {
                            selectedTask = task
                        }
                }
            }
        }
    }
}

struct ReportTaskRow: View {
    let task: Task
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isCompleted ? AppColors.success : AppColors.warning)
                .font(.title3)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(task.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textPrimary)

                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            PointsBadge(points: task.weight.rawValue, isCompleted: isCompleted)
        }
        .padding(AppSpacing.md)
        .background(AppColors.cardBackground)
        .cornerRadius(AppCornerRadius.sm)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 1)
    }
}

struct TaskDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let task: Task

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.secondaryBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // Task header
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            HStack {
                                Text(task.title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppColors.textPrimary)
                                Spacer()
                                PointsBadge(points: task.weight.rawValue, size: .large)
                            }

                            if !task.description.isEmpty {
                                Text(task.description)
                                    .font(.body)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                        .padding(AppSpacing.lg)
                        .background(AppColors.cardBackground)
                        .cornerRadius(AppCornerRadius.md)

                        // Task details
                        VStack(spacing: 0) {
                            DetailRow(label: "ステータス", value: task.status.rawValue)
                            Divider()
                            DetailRow(
                                label: "完了状況",
                                value: task.isCompleted ? "完了" : "未完了",
                                valueColor: task.isCompleted ? AppColors.success : AppColors.warning
                            )
                            Divider()
                            DetailRow(label: "作成日", value: task.createdAt.formatted(date: .abbreviated, time: .omitted))
                            if task.updatedAt != task.createdAt {
                                Divider()
                                DetailRow(label: "更新日", value: task.updatedAt.formatted(date: .abbreviated, time: .omitted))
                            }
                        }
                        .background(AppColors.cardBackground)
                        .cornerRadius(AppCornerRadius.md)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.md)
                }
            }
            .navigationTitle("タスク詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primary)
                }
            }
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    var valueColor: Color = AppColors.textPrimary

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(valueColor)
        }
        .padding(AppSpacing.lg)
    }
}

#Preview {
    ReportListView(viewModel: TaskViewModel())
}
