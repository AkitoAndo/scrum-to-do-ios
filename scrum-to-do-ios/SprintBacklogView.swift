import SwiftUI

struct SprintBacklogView: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var showingPlanning = false
    @State private var isReorderMode = false
    @State private var editingTask: Task?
    @State private var showingEndSprintAlert = false

    private var completedPoints: Int {
        viewModel.sprintTasks.filter { $0.isCompleted }.reduce(0) { $0 + $1.weight.rawValue }
    }

    private var totalPoints: Int {
        viewModel.sprintTasks.reduce(0) { $0 + $1.weight.rawValue }
    }

    private var progress: Double {
        guard totalPoints > 0 else { return 0 }
        return Double(completedPoints) / Double(totalPoints)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.secondaryBackground
                    .ignoresSafeArea()

                if viewModel.isSprintActive {
                    activeSprintView
                } else {
                    noSprintView
                }
            }
            .navigationTitle("スプリント")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if viewModel.isSprintActive {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: AppSpacing.md) {
                            Button(action: { isReorderMode.toggle() }) {
                                Image(systemName: "arrow.up.arrow.down")
                                    .foregroundColor(isReorderMode ? AppColors.accent : AppColors.primary)
                            }

                            Button(action: { showingEndSprintAlert = true }) {
                                Text("終了")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, AppSpacing.md)
                                    .padding(.vertical, AppSpacing.sm)
                                    .background(AppColors.accent)
                                    .cornerRadius(AppCornerRadius.sm)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingPlanning) {
                SprintPlanningView(viewModel: viewModel)
            }
            .sheet(item: $editingTask) { task in
                TaskFormView(viewModel: viewModel, task: task)
            }
            .alert("スプリントを終了", isPresented: $showingEndSprintAlert) {
                Button("キャンセル", role: .cancel) { }
                Button("終了", role: .destructive) {
                    viewModel.endSprint()
                }
            } message: {
                Text("スプリントを終了しますか？未完了のタスクはバックログに戻されます。")
            }
        }
    }

    private var noSprintView: some View {
        EmptyStateView(
            icon: "flame",
            title: "スプリント未開始",
            description: "スプリントプランニングを開始して\n次のイテレーションを計画しましょう",
            buttonTitle: "プランニング開始",
            buttonAction: { showingPlanning = true }
        )
    }

    private var activeSprintView: some View {
        VStack(spacing: 0) {
            // Progress dashboard
            VStack(spacing: AppSpacing.lg) {
                HStack(spacing: AppSpacing.xl) {
                    // Progress circle
                    CircularProgressView(progress: progress, size: 90, lineWidth: 10)

                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("完了ポイント")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                            Text("\(completedPoints) / \(totalPoints)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.textPrimary)
                        }

                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("残りタスク")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                            Text("\(viewModel.sprintTasks.filter { !$0.isCompleted }.count)件")
                                .font(.headline)
                                .foregroundColor(AppColors.warning)
                        }
                    }

                    Spacer()
                }
            }
            .padding(AppSpacing.lg)
            .background(AppColors.cardBackground)
            .cornerRadius(AppCornerRadius.lg)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)

            // Task list
            ScrollView {
                LazyVStack(spacing: AppSpacing.md) {
                    ForEach(viewModel.sprintTasks) { task in
                        SprintTaskRowView(
                            task: task,
                            onEdit: { editingTask = task },
                            onMoveUp: { viewModel.moveSprintTaskUp(task) },
                            onMoveDown: { viewModel.moveSprintTaskDown(task) },
                            onToggleCompletion: { viewModel.toggleSprintTaskCompletion(task) },
                            isReorderMode: isReorderMode
                        )
                        .onTapGesture {
                            if !isReorderMode {
                                editingTask = task
                            }
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, AppSpacing.xl)
            }
        }
    }
}

#Preview {
    SprintBacklogView(viewModel: TaskViewModel())
}
