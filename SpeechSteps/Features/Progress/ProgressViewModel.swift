import SwiftUI
import SwiftData

/// Aggregates practice history into the small number of figures a parent (and their SLP)
/// actually want: how often we practised, how it's trending, and which words are coming
/// along. All derived, all testable, no storage of its own.
@Observable
final class ProgressViewModel {

    struct DayBar: Identifiable {
        var id: Date { date }
        let date: Date
        let successes: Int
        let total: Int
    }

    struct TargetProgress: Identifiable {
        var id: String { word }
        let word: String
        let successes: Int
        let total: Int
        var rate: Double { total == 0 ? 0 : Double(successes) / Double(total) }
    }

    /// Practice counts per day for the last `days` days, oldest first (zero-filled).
    func dailyBars(_ child: Child, days: Int = 14,
                   now: Date = Date(), calendar: Calendar = .current) -> [DayBar] {
        let today = calendar.startOfDay(for: now)
        var totals: [Date: (s: Int, t: Int)] = [:]
        for session in child.sessions {
            let day = calendar.startOfDay(for: session.startedAt)
            let prev = totals[day] ?? (0, 0)
            totals[day] = (prev.s + session.successCount, prev.t + session.totalCount)
        }
        return (0..<days).reversed().compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let v = totals[day] ?? (0, 0)
            return DayBar(date: day, successes: v.s, total: v.t)
        }
    }

    /// Per-word totals across every session, best-practised first.
    func perTarget(_ child: Child) -> [TargetProgress] {
        var map: [String: (s: Int, t: Int)] = [:]
        for session in child.sessions {
            for trial in session.trials {
                let prev = map[trial.targetText] ?? (0, 0)
                map[trial.targetText] = (prev.s + (trial.rating.isSuccess ? 1 : 0), prev.t + 1)
            }
        }
        return map
            .map { TargetProgress(word: $0.key, successes: $0.value.s, total: $0.value.t) }
            .sorted { $0.total > $1.total }
    }

    func totalSessions(_ child: Child) -> Int { child.sessions.filter { $0.totalCount > 0 }.count }
    func totalSuccesses(_ child: Child) -> Int { child.sessions.reduce(0) { $0 + $1.successCount } }
    func totalTrials(_ child: Child) -> Int { child.sessions.reduce(0) { $0 + $1.totalCount } }

    /// A word counts as "coming along well" once it has a solid run of successful reps.
    func masteredCount(_ child: Child, threshold: Int = 8) -> Int {
        perTarget(child).filter { $0.successes >= threshold && $0.rate >= 0.8 }.count
    }
}
