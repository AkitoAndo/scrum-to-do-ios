import SwiftUI

struct SprintPlanningView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TaskViewModel
    @State private var editingTask: Task?

    private var availableTasks: [Task] {
        viewModel.tasks.filter { task in
            !viewModel.planningSprintTasks.contains(where: { $0.id == task.id })
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.secondaryBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Velocity info card
                    velocityInfoCard
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.top, AppSpacing.md)

                    // Two column layout
                    GeometryReader { geometry in
                        HStack(spacing: AppSpacing.md) {
                            // Product backlog column
                            backlogColumn(width: (geometry.size.width - AppSpacing.md) / 2)

                            // Sprint backlog column
                            sprintColumn(width: (geometry.size.width - AppSpacing.md) / 2)
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.vertical, AppSpacing.md)
                    }
                }
            }
            .navigationTitle("プランニング")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        viewModel.clearPlanningSprint()
                        dismiss()
                    }
                    .foregroundColor(AppColors.textSecondary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.startSprint()
                        dismiss()
                    }) {
                        Text("開始")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, AppSpacing.lg)
                            .padding(.vertical, AppSpacing.sm)
                            .background(
                                viewModel.planningSprintTasks.isEmpty
                                    ? Color.gray.opacity(0.5)
                                    : AppColors.primaryGradient
                            )
                            .cornerRadius(AppCornerRadius.sm)
                    }
                    .disabled(viewModel.planningSprintTasks.isEmpty)
                }
            }
            .sheet(item: $editingTask) { task in
                TaskFormView(viewModel: viewModel, task: task)
            }
        }
    }

    private var velocityInfoCard: some View {
        HStack(spacing: AppSpacing.lg) {
            // Past velocities
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("過去のベロシティ")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)

                if viewModel.pastThreeSprintVelocities.isEmpty {
                    Text("--")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textTertiary)
                } else {
                    HStack(spacing: AppSpacing.xs) {
                        ForEach(Array(viewModel.pastThreeSprintVelocities.enumerated()), id: \.offset) { _, velocity in
                            Text(String(format: "%.1f", velocity))
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppColors.primary.opacity(0.8))
                                .cornerRadius(4)
                        }
                    }
                }
            }

            Spacer()

            // Average velocity
            VStack(spacing: AppSpacing.xs) {
                Text("平均")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
                Text(String(format: "%.1f", viewModel.averageVelocity))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primary)
                Text("pt/日")
                    .font(.caption2)
                    .foregroundColor(AppColors.textTertiary)
            }

            Spacer()

            // Planning total
            VStack(spacing: AppSpacing.xs) {
                Text("計画合計")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
                Text("\(viewModel.planningSprintTotalPoints)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.success)
                Text("pt")
                    .font(.caption2)
                    .foregroundColor(AppColors.textTertiary)
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.cardBackground)
        .cornerRadius(AppCornerRadius.md)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }

    private func backlogColumn(width: CGFloat) -> some View {
        VStack(spacing: AppSpacing.sm) {
            // Header
            HStack {
                Image(systemName: "tray.full")
                    .foregroundColor(AppColors.primary)
                Text("バックログ")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(availableTasks.count)")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(AppColors.secondaryBackground)
                    .cornerRadius(8)
            }
            .padding(.horizontal, AppSpacing.sm)

            // Task list
            ScrollView {
                LazyVStack(spacing: AppSpacing.sm) {
                    ForEach(availableTasks) { task in
                        PlanningTaskRow(
                            task: task,
                            isInSprint: false,
                            onAction: {
                                withAnimation(.spring(response: 0.3)) {
                                    viewModel.moveTaskToPlanningSprint(task)
                                }
                            },
                            onTap: { editingTask = task }
                        )
                    }
                }
                .padding(.horizontal, AppSpacing.xs)
            }
        }
        .frame(width: width)
        .padding(AppSpacing.sm)
        .background(AppColors.cardBackground)
        .cornerRadius(AppCornerRadius.md)
    }

    private func sprintColumn(width: CGFloat) -> some View {
        VStack(spacing: AppSpacing.sm) {
            // Header
            HStack {
                Image(systemName: "flame")
                    .foregroundColor(AppColors.accent)
                Text("スプリント")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(viewModel.planningSprintTasks.count)")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(AppColors.secondaryBackground)
                    .cornerRadius(8)
            }
            .padding(.horizontal, AppSpacing.sm)

            // Task list
            if viewModel.planningSprintTasks.isEmpty {
                VStack(spacing: AppSpacing.md) {
                    Spacer()
                    Image(systemName: "arrow.left")
                        .font(.title)
                        .foregroundColor(AppColors.textTertiary)
                    Text("タスクを追加")
                        .font(.caption)
                        .foregroundColor(AppColors.textTertiary)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: AppSpacing.sm) {
                        ForEach(viewModel.planningSprintTasks) { task in
                            PlanningTaskRow(
                                task: task,
                                isInSprint: true,
                                onAction: {
                                    withAnimation(.spring(response: 0.3)) {
                                        viewModel.moveTaskFromPlanningSprint(task)
                                    }
                                },
                                onTap: { editingTask = task }
                            )
                        }
                    }
                    .padding(.horizontal, AppSpacing.xs)
                }
            }
        }
        .frame(width: width)
        .padding(AppSpacing.sm)
        .background(AppColors.cardBackground)
        .cornerRadius(AppCornerRadius.md)
    }
}

struct PlanningTaskRow: View {
    let task: Task
    let isInSprint: Bool
    let onAction: () -> Void
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)

                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.caption2)
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            PointsBadge(points: task.weight.rawValue, size: .small)

            Button(action: onAction) {
                Image(systemName: isInSprint ? "minus.circle.fill" : "plus.circle.fill")
                    .font(.title3)
                    .foregroundColor(isInSprint ? AppColors.error : AppColors.success)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.sm)
        .background(AppColors.secondaryBackground)
        .cornerRadius(AppCornerRadius.sm)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

#Preview {
    SprintPlanningView(viewModel: TaskViewModel())
}
