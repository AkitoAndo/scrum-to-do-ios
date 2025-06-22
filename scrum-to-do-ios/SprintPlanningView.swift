import SwiftUI

struct SprintPlanningView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TaskViewModel
    @State private var editingTask: Task?
    
    var body: some View {
        VStack(spacing: 0) {
            // カスタムナビゲーションバー
            HStack {
                Button("キャンセル") {
                    viewModel.clearPlanningSprint()
                    dismiss()
                }
                .foregroundColor(.white)
                
                Spacer()
                
                Text("スプリントプランニング")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("開始") {
                    viewModel.startSprint()
                    dismiss()
                }
                .disabled(viewModel.planningSprintTasks.isEmpty)
                .foregroundColor(.white)
            }
            .padding()
            .background(Color(red: 0.6, green: 0.5, blue: 0.4))
            
            // ベロシティ情報とプランニング総計
            VStack(spacing: 12) {
                HStack {
                    Text("ベロシティ情報")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                }
                
                HStack(spacing: 16) {
                    // 過去3回のベロシティ
                    VStack(alignment: .leading, spacing: 4) {
                        Text("過去のベロシティ")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if viewModel.pastThreeSprintVelocities.isEmpty {
                            Text("データなし")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(Array(viewModel.pastThreeSprintVelocities.enumerated()), id: \.offset) { index, velocity in
                                Text("\(String(format: "%.1f", velocity)) pt/日")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // 平均ベロシティ
                    VStack(alignment: .center, spacing: 4) {
                        Text("平均ベロシティ")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(String(format: "%.1f", viewModel.averageVelocity)) pt/日")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    // 現在のプランニング総計
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("プランニング総計")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(viewModel.planningSprintTotalPoints) pt")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            
            HStack(spacing: 0) {
                VStack {
                    Text("プロダクトバックログ")
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .padding()
                    
                    List {
                        ForEach(viewModel.tasks.filter { task in
                            !viewModel.planningSprintTasks.contains(where: { $0.id == task.id })
                        }) { task in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(task.title)
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    
                                    if !task.description.isEmpty {
                                        Text(task.description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                    }
                                }
                                
                                Spacer()
                                
                                // Weight表示
                                Text("\(task.weight.rawValue)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(red: 0.6, green: 0.5, blue: 0.4))
                                    .cornerRadius(12)
                                
                                Button(action: {
                                    withAnimation {
                                        viewModel.moveTaskToPlanningSprint(task)
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.title2)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.vertical, 2)
                            .onTapGesture {
                                editingTask = task
                            }
                        }
                        .listRowSeparator(.visible)
                    }
                    .listStyle(PlainListStyle())
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Text("スプリントバックログ")
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .padding()
                    
                    List {
                        ForEach(viewModel.planningSprintTasks) { task in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(task.title)
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    
                                    if !task.description.isEmpty {
                                        Text(task.description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                    }
                                }
                                
                                Spacer()
                                
                                // Weight表示
                                Text("\(task.weight.rawValue)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(red: 0.6, green: 0.5, blue: 0.4))
                                    .cornerRadius(12)
                                
                                Button(action: {
                                    withAnimation {
                                        viewModel.moveTaskFromPlanningSprint(task)
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.title2)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.vertical, 2)
                            .onTapGesture {
                                editingTask = task
                            }
                        }
                        .listRowSeparator(.visible)
                    }
                    .listStyle(PlainListStyle())
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
        }
        .sheet(item: $editingTask) { task in
            TaskFormView(viewModel: viewModel, task: task)
        }
    }
}

#Preview {
    SprintPlanningView(viewModel: TaskViewModel())
}