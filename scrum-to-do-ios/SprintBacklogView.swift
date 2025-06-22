import SwiftUI

struct SprintBacklogView: View {
    @ObservedObject var viewModel: TaskViewModel
    let showMenu: () -> Void
    @State private var showingPlanning = false
    @State private var isReorderMode = false
    @State private var editingTask: Task?
    
    var body: some View {
        VStack(spacing: 0) {
            // カスタムナビゲーションバー - 絶対に色が変わらない
            HStack {
                Button(action: showMenu) {
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(.white)
                        .font(.title2)
                }
                
                Spacer()
                
                Text("スプリントバックログ")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                if viewModel.isSprintActive {
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
                        
                        Button("スプリントを終了") {
                            viewModel.endSprint()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(red: 0.6, green: 0.5, blue: 0.4))
            
            // メインコンテンツ
            if viewModel.isSprintActive {
                List {
                    ForEach(viewModel.sprintTasks) { task in
                        SprintTaskRowView(
                            task: task,
                            onEdit: {
                                editingTask = task
                            },
                            onMoveUp: {
                                viewModel.moveSprintTaskUp(task)
                            },
                            onMoveDown: {
                                viewModel.moveSprintTaskDown(task)
                            },
                            onToggleCompletion: {
                                viewModel.toggleSprintTaskCompletion(task)
                            },
                            isReorderMode: isReorderMode
                        )
                        .onTapGesture {
                            if !isReorderMode {
                                editingTask = task
                            }
                        }
                        .listRowBackground(Color(.systemGray6))
                    }
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
                .background(Color(.systemGray6))
            } else {
                VStack {
                    Spacer()
                    
                    Text("スプリントが開始されていません")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .padding()
                    
                    Button("スプリントプランニングを開始") {
                        showingPlanning = true
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                    
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showingPlanning) {
            SprintPlanningView(viewModel: viewModel)
        }
        .onChange(of: showingPlanning) { oldValue, newValue in
            print("showingPlanning changed: \(oldValue) -> \(newValue)")
        }
        .sheet(item: $editingTask) { task in
            TaskFormView(viewModel: viewModel, task: task)
        }
    }
}

#Preview {
    SprintBacklogView(viewModel: TaskViewModel(), showMenu: {})
}