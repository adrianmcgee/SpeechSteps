import Foundation
import SwiftData

/// One short home-practice session — by design a few minutes, several times a day beats
/// one long block. Holds the trials logged during it and a cached summary for quick reads.
@Model
final class PracticeSession {
    var startedAt: Date = Date()
    var endedAt: Date?
    /// Cached so charts and the home streak don't have to walk every trial.
    var successCount: Int = 0
    var totalCount: Int = 0

    var child: Child?

    @Relationship(deleteRule: .cascade, inverse: \Trial.session)
    var trials: [Trial] = []

    init(startedAt: Date = Date()) {
        self.startedAt = startedAt
    }

    var durationSeconds: Int {
        guard let endedAt else { return 0 }
        return max(0, Int(endedAt.timeIntervalSince(startedAt)))
    }

    /// Share of successful reps — the figure that reflects motor-learning quality.
    var successRate: Double {
        totalCount == 0 ? 0 : Double(successCount) / Double(totalCount)
    }

    /// Recompute the cached counts from the trials. Call after logging.
    func refreshSummary() {
        totalCount = trials.count
        successCount = trials.filter { $0.rating == .correct }.count
    }
}
