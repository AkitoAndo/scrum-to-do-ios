import SwiftUI

struct MainNavigationView: View {
    @StateObject private var viewModel = TaskViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ProductBacklogView(viewModel: viewModel)
                .tabItem {
                    Label("バックログ", systemImage: "list.bullet.rectangle.portrait")
                }
                .tag(0)

            SprintBacklogView(viewModel: viewModel)
                .tabItem {
                    Label("スプリント", systemImage: "flame")
                }
                .tag(1)

            ReportListView(viewModel: viewModel)
                .tabItem {
                    Label("レポート", systemImage: "chart.bar.xaxis")
                }
                .tag(2)
        }
        .tint(AppColors.primary)
    }
}

#Preview {
    MainNavigationView()
}
