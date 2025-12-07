import SwiftUI

struct TaskFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TaskViewModel

    @State private var title = ""
    @State private var description = ""
    @State private var selectedWeight: FibonacciWeight = .three
    @State private var showingDeleteAlert = false

    let task: Task?

    init(viewModel: TaskViewModel, task: Task? = nil) {
        self.viewModel = viewModel
        self.task = task

        if let task = task {
            self._title = State(initialValue: task.title)
            self._description = State(initialValue: task.description)
            self._selectedWeight = State(initialValue: task.weight)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.secondaryBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // Task info section
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            Text("タスク情報")
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary)

                            VStack(spacing: AppSpacing.md) {
                                // Title field
                                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                    Text("タスク名")
                                        .font(.caption)
                                        .foregroundColor(AppColors.textSecondary)

                                    TextField("タスク名を入力", text: $title)
                                        .font(.body)
                                        .padding(AppSpacing.md)
                                        .background(AppColors.secondaryBackground)
                                        .cornerRadius(AppCornerRadius.sm)
                                }

                                // Description field
                                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                    Text("説明（任意）")
                                        .font(.caption)
                                        .foregroundColor(AppColors.textSecondary)

                                    TextField("説明を入力", text: $description, axis: .vertical)
                                        .font(.body)
                                        .lineLimit(3...6)
                                        .padding(AppSpacing.md)
                                        .background(AppColors.secondaryBackground)
                                        .cornerRadius(AppCornerRadius.sm)
                                }
                            }
                        }
                        .padding(AppSpacing.lg)
                        .background(AppColors.cardBackground)
                        .cornerRadius(AppCornerRadius.md)

                        // Story points section
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            Text("ストーリーポイント")
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary)

                            StoryPointSelector(selectedWeight: $selectedWeight)
                        }
                        .padding(AppSpacing.lg)
                        .background(AppColors.cardBackground)
                        .cornerRadius(AppCornerRadius.md)

                        // Delete button (only for editing)
                        if task != nil {
                            Button(action: { showingDeleteAlert = true }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("タスクを削除")
                                }
                                .font(.headline)
                                .foregroundColor(AppColors.error)
                                .frame(maxWidth: .infinity)
                                .padding(AppSpacing.lg)
                                .background(AppColors.error.opacity(0.1))
                                .cornerRadius(AppCornerRadius.md)
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.md)
                }
            }
            .navigationTitle(task == nil ? "新しいタスク" : "タスク編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.textSecondary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: saveTask) {
                        Text("保存")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, AppSpacing.lg)
                            .padding(.vertical, AppSpacing.sm)
                            .background(
                                title.isEmpty
                                    ? Color.gray.opacity(0.5)
                                    : AppColors.primaryGradient
                            )
                            .cornerRadius(AppCornerRadius.sm)
                    }
                    .disabled(title.isEmpty)
                }
            }
            .alert("タスクを削除", isPresented: $showingDeleteAlert) {
                Button("キャンセル", role: .cancel) { }
                Button("削除", role: .destructive) {
                    if let task = task {
                        viewModel.deleteTask(task)
                    }
                    dismiss()
                }
            } message: {
                Text("このタスクを削除しますか？この操作は取り消せません。")
            }
        }
    }

    private func saveTask() {
        if let task = task {
            viewModel.updateTask(task, title: title, description: description, weight: selectedWeight)
        } else {
            viewModel.addTask(title: title, description: description, weight: selectedWeight)
        }
        dismiss()
    }
}

struct StoryPointSelector: View {
    @Binding var selectedWeight: FibonacciWeight

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: AppSpacing.sm) {
            ForEach(FibonacciWeight.allCases, id: \.self) { weight in
                StoryPointButton(
                    weight: weight,
                    isSelected: selectedWeight == weight,
                    action: { selectedWeight = weight }
                )
            }
        }
    }
}

struct StoryPointButton: View {
    let weight: FibonacciWeight
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.xs) {
                Text("\(weight.rawValue)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white : AppColors.textPrimary)

                Text("pt")
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background(
                isSelected
                    ? AnyShapeStyle(AppColors.primaryGradient)
                    : AnyShapeStyle(AppColors.secondaryBackground)
            )
            .cornerRadius(AppCornerRadius.sm)
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                    .stroke(isSelected ? Color.clear : AppColors.textTertiary.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.2), value: isSelected)
    }
}

#Preview {
    TaskFormView(viewModel: TaskViewModel())
}
