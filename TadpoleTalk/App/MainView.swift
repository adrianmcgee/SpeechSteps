import SwiftUI

/// The app's primary destinations. One enum drives both the iPhone tab bar and the iPad
/// sidebar so the two layouts never drift apart.
enum AppSection: String, CaseIterable, Identifiable {
    case today, targets, library, progress, learn
    var id: String { rawValue }

    var title: String {
        switch self {
        case .today: return "Today"
        case .targets: return "Targets"
        case .library: return "Library"
        case .progress: return "Progress"
        case .learn: return "Learn"
        }
    }

    var symbol: String {
        switch self {
        case .today: return "house.fill"
        case .targets: return "target"
        case .library: return "books.vertical.fill"
        case .progress: return "chart.line.uptrend.xyaxis"
        case .learn: return "lightbulb.fill"
        }
    }

    var a11yID: String {
        switch self {
        case .today: return A11y.tabToday
        case .targets: return A11y.tabTargets
        case .library: return A11y.tabSounds
        case .progress: return A11y.tabProgress
        case .learn: return A11y.tabLearn
        }
    }
}

/// Adaptive shell: a sidebar split where there's room (iPad, big-phone landscape), the tab
/// bar where it's compact.
struct MainView: View {
    @Environment(\.horizontalSizeClass) private var hSize
    let child: Child

    var body: some View {
        if hSize == .regular {
            SidebarLayout(child: child)
        } else {
            TabLayout(child: child)
        }
    }

    @ViewBuilder
    static func destination(_ section: AppSection, child: Child) -> some View {
        switch section {
        case .today: TodayView(child: child)
        case .targets: TargetListView(child: child)
        case .library: LibraryView()
        case .progress: ProgressDashboardView(child: child)
        case .learn: LearnView()
        }
    }
}

private struct TabLayout: View {
    let child: Child

    var body: some View {
        TabView {
            ForEach(AppSection.allCases) { section in
                MainView.destination(section, child: child)
                    .tabItem { Label(section.title, systemImage: section.symbol) }
                    .accessibilityIdentifier(section.a11yID)
            }
        }
    }
}

private struct SidebarLayout: View {
    let child: Child
    @State private var selection: AppSection? = .today

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                ForEach(AppSection.allCases) { section in
                    Label(section.title, systemImage: section.symbol)
                        .tag(section)
                        .accessibilityIdentifier(section.a11yID)
                }
            }
            .navigationTitle("Tadpole Talk")
        } detail: {
            MainView.destination(selection ?? .today, child: child)
                .id(selection)
        }
    }
}
