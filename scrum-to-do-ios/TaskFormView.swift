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
            Form {
                Section(header: Text("タスク情報")) {
                    TextField("タスク名", text: $title)
                    TextField("説明", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("ストーリーポイント")) {
                    Picker("ポイント", selection: $selectedWeight) {
                        ForEach(FibonacciWeight.allCases, id: \.self) { weight in
                            Text("\(weight.displayName)")
                                .tag(weight)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                if task != nil {
                    Section {
                        Button("削除", role: .destructive) {
                            showingDeleteAlert = true
                        }
                    }
                }
            }
            .navigationTitle(task == nil ? "新しいタスク" : "タスク編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveTask()
                    }
                    .disabled(title.isEmpty)
                    .foregroundColor(.white)
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(red: 0.6, green: 0.5, blue: 0.4), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("タスクを削除", isPresented: $showingDeleteAlert) {
                Button("削除", role: .destructive) {
                    if let task = task {
                        viewModel.deleteTask(task)
                    }
                    dismiss()
                }
                Button("キャンセル", role: .cancel) { }
            } message: {
                Text("このタスクを削除しますか？")
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

#Preview {
    TaskFormView(viewModel: TaskViewModel())
}