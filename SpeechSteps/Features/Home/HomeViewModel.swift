import SwiftUI
import SwiftData

/// Derives the encouraging, at-a-glance numbers Today shows from the child's session
/// history. Logic lives here (not the view) so the streak/“little & often” rules are
/// unit-testable.
@Observable
final class HomeViewModel {
    /// Practice sessions completed today.
    func sessionsToday(_ child: Child, now: Date = Date(), calendar: Calendar = .current) -> Int {
        child.sessions.filter { calendar.isDate($0.startedAt, inSameDayAs: now) && $0.totalCount > 0 }.count
    }

    /// Successful reps logged today — the figure that reflects quality practice.
    func successesToday(_ child: Child, now: Date = Date(), calendar: Calendar = .current) -> Int {
        child.sessions
            .filter { calendar.isDate($0.startedAt, inSameDayAs: now) }
            .reduce(0) { $0 + $1.successCount }
    }

    /// Consecutive days (ending today or yesterday) with at least one real session.
    /// Counting from yesterday too means an early-morning open doesn't show a broken streak.
    func streak(_ child: Child, now: Date = Date(), calendar: Calendar = .current) -> Int {
        let days = Set(child.sessions
            .filter { $0.totalCount > 0 }
            .map { calendar.startOfDay(for: $0.startedAt) })
        guard !days.isEmpty else { return 0 }

        let today = calendar.startOfDay(for: now)
        var cursor = today
        if !days.contains(today) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                  days.contains(yesterday) else { return 0 }
            cursor = yesterday
        }
        var count = 0
        while days.contains(cursor) {
            count += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }
        return count
    }

    /// Gentle, time-of-day-aware nudge that reflects the “a few minutes, several times a
    /// day” evidence rather than a single long block.
    func encouragement(_ child: Child, now: Date = Date()) -> String {
        let done = sessionsToday(child, now: now)
        switch done {
        case 0: return "A few minutes is plenty. Ready for a quick go?"
        case 1: return "Lovely start. Another short go later keeps it sticking."
        case 2: return "Two practices today — you're doing brilliantly."
        default: return "Wonderful. Little and often is exactly right."
        }
    }
}
