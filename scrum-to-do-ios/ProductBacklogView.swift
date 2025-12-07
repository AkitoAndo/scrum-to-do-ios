import SwiftUI

struct ProductBacklogView: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var showingAddTask = false
    @State private var editingTask: Task?
    @State private var isReorderMode = false

    private var totalPoints: Int {
        viewModel.tasks.reduce(0) { $0 + $1.weight.rawValue }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.secondaryBackground
                    .ignoresSafeArea()

                if viewModel.tasks.isEmpty {
                    EmptyStateView(
                        icon: "tray",
                        title: "バックログが空です",
                        description: "タスクを追加して\nプロダクトバックログを作成しましょう",
                        buttonTitle: "タスクを追加",
                        buttonAction: { showingAddTask = true }
                    )
                } else {
                    VStack(spacing: 0) {
                        // Stats header
                        HStack(spacing: AppSpacing.md) {
                            StatCard(
                                title: "タスク数",
                                value: "\(viewModel.tasks.count)",
                                icon: "list.bullet",
                                color: AppColors.primary
                            )
                            StatCard(
                                title: "合計ポイント",
                                value: "\(totalPoints)",
                                subtitle: "pt",
                                icon: "chart.bar.fill",
                                color: AppColors.accent
                            )
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.vertical, AppSpacing.md)

                        // Task list
                        ScrollView {
                            LazyVStack(spacing: AppSpacing.md) {
                                ForEach(viewModel.tasks) { task in
                                    TaskRowView(
                                        task: task,
                                        onEdit: { editingTask = task },
                                        onDragHandleTouch: {},
                                        onMoveUp: { viewModel.moveTaskUp(task) },
                                        onMoveDown: { viewModel.moveTaskDown(task) },
                                        isReorderMode: isReorderMode
                                    )
                                    .onTapGesture {
                                        if !isReorderMode {
                                            editingTask = task
                                        }
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            if let index = viewModel.tasks.firstIndex(where: { $0.id == task.id }) {
                                                viewModel.deleteTask(at: IndexSet(integer: index))
                                            }
                                        } label: {
                                            Label("削除", systemImage: "trash")
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
            .navigationTitle("バックログ")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: AppSpacing.md) {
                        Button(action: { isReorderMode.toggle() }) {
                            Image(systemName: "arrow.up.arrow.down")
                                .foregroundColor(isReorderMode ? AppColors.accent : AppColors.primary)
                        }

                        Button(action: { showingAddTask = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(AppColors.primaryGradient)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                TaskFormView(viewModel: viewModel)
            }
            .sheet(item: $editingTask) { task in
                TaskFormView(viewModel: viewModel, task: task)
            }
        }
    }
}

#Preview {
    ProductBacklogView(viewModel: TaskViewModel())
}
