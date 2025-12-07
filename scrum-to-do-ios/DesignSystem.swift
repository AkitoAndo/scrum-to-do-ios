import SwiftUI

// MARK: - Color Palette
struct AppColors {
    // Primary Colors - Modern Indigo/Purple gradient
    static let primary = Color(red: 0.35, green: 0.34, blue: 0.84)
    static let primaryLight = Color(red: 0.47, green: 0.45, blue: 0.95)
    static let primaryDark = Color(red: 0.25, green: 0.24, blue: 0.70)

    // Accent Colors
    static let accent = Color(red: 0.98, green: 0.36, blue: 0.55)
    static let accentLight = Color(red: 1.0, green: 0.50, blue: 0.65)

    // Semantic Colors
    static let success = Color(red: 0.20, green: 0.78, blue: 0.55)
    static let successLight = Color(red: 0.30, green: 0.88, blue: 0.65)
    static let warning = Color(red: 1.0, green: 0.72, blue: 0.30)
    static let error = Color(red: 0.95, green: 0.30, blue: 0.35)

    // Neutral Colors
    static let background = Color(UIColor.systemBackground)
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
    static let cardBackground = Color(UIColor.systemBackground)

    // Text Colors
    static let textPrimary = Color(UIColor.label)
    static let textSecondary = Color(UIColor.secondaryLabel)
    static let textTertiary = Color(UIColor.tertiaryLabel)

    // Gradients
    static let primaryGradient = LinearGradient(
        colors: [primaryLight, primary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        colors: [accentLight, accent],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let successGradient = LinearGradient(
        colors: [successLight, success],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Spacing
struct AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}

// MARK: - Corner Radius
struct AppCornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
}

// MARK: - Card Component
struct AppCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = AppSpacing.lg
    var cornerRadius: CGFloat = AppCornerRadius.md

    init(padding: CGFloat = AppSpacing.lg, cornerRadius: CGFloat = AppCornerRadius.md, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        content
            .padding(padding)
            .background(AppColors.cardBackground)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Task Card Component
struct TaskCard: View {
    let title: String
    let description: String
    let points: Int
    var isCompleted: Bool = false
    var statusColor: Color = AppColors.primary
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: 0) {
                // Status color bar
                RoundedRectangle(cornerRadius: 2)
                    .fill(isCompleted ? AppColors.success : statusColor)
                    .frame(width: 4)
                    .padding(.vertical, 4)

                HStack(spacing: AppSpacing.md) {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(isCompleted ? AppColors.textSecondary : AppColors.textPrimary)
                            .strikethrough(isCompleted)
                            .lineLimit(2)

                        if !description.isEmpty {
                            Text(description)
                                .font(.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                                .lineLimit(2)
                        }
                    }

                    Spacer()

                    PointsBadge(points: points, isCompleted: isCompleted)
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
            }
            .background(AppColors.cardBackground)
            .cornerRadius(AppCornerRadius.md)
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Points Badge
struct PointsBadge: View {
    let points: Int
    var isCompleted: Bool = false
    var size: BadgeSize = .medium

    enum BadgeSize {
        case small, medium, large

        var fontSize: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption
            case .large: return .subheadline
            }
        }

        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6)
            case .medium: return EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10)
            case .large: return EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 14)
            }
        }
    }

    var body: some View {
        Text("\(points)")
            .font(size.fontSize)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(size.padding)
            .background(
                Capsule()
                    .fill(isCompleted ? Color.gray.opacity(0.5) : AppColors.primaryGradient)
            )
    }
}

// MARK: - Circular Progress View
struct CircularProgressView: View {
    let progress: Double
    var size: CGFloat = 80
    var lineWidth: CGFloat = 8
    var showPercentage: Bool = true

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(AppColors.primary.opacity(0.2), lineWidth: lineWidth)

            // Progress circle
            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    AppColors.primaryGradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)

            // Percentage text
            if showPercentage {
                VStack(spacing: 0) {
                    Text("\(Int(progress * 100))")
                        .font(.system(size: size * 0.28, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    Text("%")
                        .font(.system(size: size * 0.14, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    var subtitle: String? = nil
    var icon: String? = nil
    var color: Color = AppColors.primary

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                }
                Text(title)
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(AppColors.textTertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.md)
        .background(AppColors.secondaryBackground)
        .cornerRadius(AppCornerRadius.md)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    var buttonTitle: String? = nil
    var buttonAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundStyle(AppColors.primaryGradient)

            VStack(spacing: AppSpacing.sm) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.xl)
            }

            if let buttonTitle = buttonTitle, let action = buttonAction {
                Button(action: action) {
                    Text(buttonTitle)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, AppSpacing.xl)
                        .padding(.vertical, AppSpacing.md)
                        .background(AppColors.primaryGradient)
                        .cornerRadius(AppCornerRadius.lg)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}

// MARK: - Navigation Header
struct NavigationHeader: View {
    let title: String
    var leadingAction: (() -> Void)? = nil
    var leadingIcon: String = "line.3.horizontal"
    var trailingActions: [HeaderAction] = []

    struct HeaderAction: Identifiable {
        let id = UUID()
        let icon: String
        let action: () -> Void
        var isActive: Bool = false
    }

    var body: some View {
        HStack(spacing: AppSpacing.lg) {
            if let action = leadingAction {
                Button(action: action) {
                    Image(systemName: leadingIcon)
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }

            Spacer()

            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Spacer()

            HStack(spacing: AppSpacing.md) {
                ForEach(trailingActions) { action in
                    Button(action: action.action) {
                        Image(systemName: action.icon)
                            .font(.title3)
                            .foregroundColor(action.isActive ? AppColors.accent : .white)
                    }
                }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
        .background(AppColors.primaryGradient)
    }
}

// MARK: - Primary Button Style
struct PrimaryButtonStyle: ButtonStyle {
    var isDisabled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, AppSpacing.xl)
            .padding(.vertical, AppSpacing.md)
            .background(
                Group {
                    if isDisabled {
                        Color.gray.opacity(0.5)
                    } else {
                        AppColors.primaryGradient
                    }
                }
            )
            .cornerRadius(AppCornerRadius.lg)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(AppColors.primary)
            .padding(.horizontal, AppSpacing.xl)
            .padding(.vertical, AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                    .stroke(AppColors.primary, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Velocity Chart
struct VelocityChart: View {
    let velocities: [Double]
    let average: Double

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("ベロシティ推移")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)

            if velocities.isEmpty {
                Text("データがありません")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
            } else {
                HStack(alignment: .bottom, spacing: AppSpacing.sm) {
                    ForEach(Array(velocities.enumerated()), id: \.offset) { index, velocity in
                        VStack(spacing: AppSpacing.xs) {
                            Text(String(format: "%.1f", velocity))
                                .font(.caption2)
                                .foregroundColor(AppColors.textSecondary)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppColors.primaryGradient)
                                .frame(width: 40, height: CGFloat(velocity / max(velocities.max() ?? 1, 1)) * 60 + 10)

                            Text("S\(velocities.count - index)")
                                .font(.caption2)
                                .foregroundColor(AppColors.textTertiary)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                        Text("平均")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                        Text(String(format: "%.1f", average))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.primary)
                        Text("pt/日")
                            .font(.caption2)
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.cardBackground)
        .cornerRadius(AppCornerRadius.md)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

#Preview("Design System") {
    ScrollView {
        VStack(spacing: 20) {
            NavigationHeader(
                title: "プレビュー",
                leadingAction: {},
                trailingActions: [
                    .init(icon: "plus", action: {})
                ]
            )

            VStack(spacing: 16) {
                TaskCard(
                    title: "サンプルタスク",
                    description: "これはサンプルの説明です",
                    points: 5
                )

                TaskCard(
                    title: "完了したタスク",
                    description: "これは完了したタスクです",
                    points: 3,
                    isCompleted: true
                )

                HStack {
                    StatCard(title: "完了ポイント", value: "21", subtitle: "今週", icon: "checkmark.circle.fill", color: AppColors.success)
                    StatCard(title: "残りポイント", value: "13", subtitle: "2タスク", icon: "clock.fill", color: AppColors.warning)
                }

                CircularProgressView(progress: 0.65)

                EmptyStateView(
                    icon: "tray",
                    title: "タスクがありません",
                    description: "新しいタスクを追加してください",
                    buttonTitle: "タスクを追加",
                    buttonAction: {}
                )
                .frame(height: 300)
            }
            .padding()
        }
    }
}
