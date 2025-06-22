import SwiftUI

struct MainNavigationView: View {
    @StateObject private var viewModel = TaskViewModel()
    @State private var selectedTab = 0
    @State private var selectedMenuItem: MenuItem = .productBacklog
    @State private var isMenuOpen = false
    @State private var dragOffset: CGFloat = 0
    
    enum MenuItem: String, CaseIterable {
        case productBacklog = "プロダクトバックログ"
        case sprintBacklog = "スプリントバックログ"
        case reports = "レポート"
        
        var icon: String {
            switch self {
            case .productBacklog: return "list.bullet"
            case .sprintBacklog: return "calendar"
            case .reports: return "chart.bar"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // メインコンテンツ（元のTabView）
            NavigationStack {
                if selectedMenuItem == .reports {
                    ReportListView(viewModel: viewModel, showMenu: toggleMenu)
                } else {
                    TabView(selection: $selectedTab) {
                        ProductBacklogView(viewModel: viewModel, showMenu: toggleMenu)
                            .tabItem {
                                Image(systemName: "list.bullet")
                                Text("プロダクトバックログ")
                            }
                            .tag(0)
                        
                        SprintBacklogView(viewModel: viewModel, showMenu: toggleMenu)
                            .tabItem {
                                Image(systemName: "calendar")
                                Text("スプリントバックログ")
                            }
                            .tag(1)
                    }
                    .accentColor(Color(red: 0.6, green: 0.5, blue: 0.4))
                    .tint(Color(red: 0.6, green: 0.5, blue: 0.4))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isMenuOpen)
            
            // 引き出しメニュー
            HStack {
                VStack(spacing: 0) {
                    // メニューヘッダー
                    HStack {
                        Text("スクラム管理")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(red: 0.6, green: 0.5, blue: 0.4))
                    
                    // メニュー項目
                    VStack(spacing: 0) {
                        ForEach(MenuItem.allCases, id: \.self) { item in
                            Button(action: {
                                handleMenuSelection(item)
                                toggleMenu()
                            }) {
                                HStack {
                                    Image(systemName: item.icon)
                                        .foregroundColor(selectedMenuItem == item ? .accentColor : .gray)
                                        .frame(width: 24)
                                    
                                    Text(item.rawValue)
                                        .foregroundColor(selectedMenuItem == item ? .accentColor : .primary)
                                        .font(.system(size: 16))
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(selectedMenuItem == item ? Color(red: 0.6, green: 0.5, blue: 0.4).opacity(0.1) : Color.clear)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider()
                                .padding(.leading, 20)
                        }
                    }
                    
                    Spacer()
                }
                .frame(width: 280)
                .background(Color(.systemBackground))
                .shadow(radius: 5)
                .offset(x: calculateMenuOffset())
                
                Spacer()
            }
            
            // 透明なオーバーレイ（メニューが開いている時のタップ検知用）
            if isMenuOpen {
                Color.clear
                    .ignoresSafeArea()
                    .onTapGesture {
                        toggleMenu()
                    }
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    // 画面全体の左半分からのスワイプでメニューを開く（より開きやすく）
                    if value.startLocation.x < UIScreen.main.bounds.width * 0.3 && value.translation.width > 10 && !isMenuOpen {
                        // リアルタイムでメニューを追従させる
                        dragOffset = value.translation.width
                    }
                    // メニューが開いている時の右スワイプで閉じる
                    else if isMenuOpen && value.translation.width < -30 {
                        dragOffset = value.translation.width
                    }
                }
                .onEnded { value in
                    // 左側からのスワイプでメニューを開く判定（緩い条件）
                    if value.startLocation.x < UIScreen.main.bounds.width * 0.3 && value.translation.width > 50 && !isMenuOpen {
                        toggleMenu()
                    }
                    // メニューが開いている時の右スワイプで閉じる判定
                    else if isMenuOpen && (value.translation.width < -80 || value.velocity.width < -200) {
                        toggleMenu()
                    }
                    // 速いスワイプでも反応するように
                    else if !isMenuOpen && value.startLocation.x < UIScreen.main.bounds.width * 0.2 && value.velocity.width > 300 {
                        toggleMenu()
                    }
                    
                    // dragOffsetをリセット
                    withAnimation(.easeOut(duration: 0.2)) {
                        dragOffset = 0
                    }
                }
        )
    }
    
    private func toggleMenu() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isMenuOpen.toggle()
        }
    }
    
    private func calculateMenuOffset() -> CGFloat {
        if isMenuOpen {
            // メニューが開いている時のオフセット計算
            return max(-280, dragOffset)
        } else {
            // メニューが閉じている時のオフセット計算
            return min(0, -280 + max(0, dragOffset))
        }
    }
    
    private func handleMenuSelection(_ item: MenuItem) {
        selectedMenuItem = item
        switch item {
        case .productBacklog:
            selectedTab = 0
        case .sprintBacklog:
            selectedTab = 1
        case .reports:
            // レポート画面は別途表示
            break
        }
    }
}



#Preview {
    MainNavigationView()
}