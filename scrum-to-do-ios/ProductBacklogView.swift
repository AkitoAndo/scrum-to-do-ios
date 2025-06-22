import SwiftUI

struct ProductBacklogView: View {
    @ObservedObject var viewModel: TaskViewModel
    let showMenu: () -> Void
    @State private var showingAddTask = false
    @State private var editingTask: Task?
    @State private var editMode: EditMode = .inactive
    @State private var isReorderMode = false
    
    var body: some View {
        VStack(spacing: 0) {
            // カスタムナビゲーションバー
            HStack {
                Button(action: showMenu) {
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(.white)
                        .font(.title2)
                }
                
                Spacer()
                
                Text("プロダクトバックログ")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack {
                    Button(action: {
                        isReorderMode.toggle()
                    }) {
                        VStack(spacing: 2) {
                            Image(systemName: "chevron.up")
                                .font(.caption)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                        .foregroundColor(isReorderMode ? .red : .white)
                    }
                    
                    Button(action: {
                        showingAddTask = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(red: 0.6, green: 0.5, blue: 0.4))
            
            // メインコンテンツ
            List {
                ForEach(viewModel.tasks) { task in
                    TaskRowView(
                        task: task,
                        onEdit: {
                            editingTask = task
                        },
                        onDragHandleTouch: {},
                        onMoveUp: {
                            viewModel.moveTaskUp(task)
                        },
                        onMoveDown: {
                            viewModel.moveTaskDown(task)
                        },
                        isReorderMode: isReorderMode
                    )
                    .moveDisabled(false)
                    .deleteDisabled(false)
                    .onTapGesture {
                        if !isReorderMode {
                            editingTask = task
                        }
                    }
                    .listRowBackground(Color(.systemGray6))
                }
                .onDelete(perform: viewModel.deleteTask)
                .onMove(perform: viewModel.moveTask)
            }
            .environment(\.editMode, $editMode)
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden)
            .background(Color(.systemGray6))
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
    ProductBacklogView(viewModel: TaskViewModel(), showMenu: {})
}