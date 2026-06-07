import SwiftUI
import SwiftData

/// Drives one practice session: which word we're on, logging each attempt, and the
/// running tally. The motor-learning rules (success counts, short sessions, celebrate the
/// wins) live here so the view is just presentation and so the logic is unit-testable.
@Observable
final class PracticeSessionViewModel {
    let targets: [WordTarget]
    private(set) var index: Int = 0
    /// Attempts logged for the current word — surfaced so a parent can aim for a few good reps.
    private(set) var repsForCurrent: Int = 0
    /// Pulses true briefly after a success so the view can celebrate.
    var celebrate: Bool = false
    private(set) var finished: Bool = false

    private let child: Child
    private let session: PracticeSession
    private let context: ModelContext

    init(child: Child, targets: [WordTarget], context: ModelContext) {
        self.child = child
        self.targets = targets
        self.context = context
        let session = PracticeSession()
        session.child = child
        context.insert(session)
        self.session = session
    }

    var currentTarget: WordTarget? { targets.indices.contains(index) ? targets[index] : nil }
    var isLastTarget: Bool { index >= targets.count - 1 }
    var progressText: String { "Word \(min(index + 1, targets.count)) of \(targets.count)" }

    var successCount: Int { session.successCount }
    var totalCount: Int { session.totalCount }

    /// The first linked sound for the current word, if any — used for the in-session diagram.
    func currentPhoneme(_ content: ContentStore = .shared) -> Phoneme? {
        guard let id = currentTarget?.phonemeIDs.first else { return nil }
        return content.phoneme(id: id)
    }

    /// Log one attempt at the current word. Successes trigger the celebration.
    func log(_ rating: TrialRating) {
        guard let target = currentTarget else { return }
        let trial = Trial(targetText: target.text, rating: rating)
        trial.session = session
        context.insert(trial)
        session.trials.append(trial)
        session.refreshSummary()
        repsForCurrent += 1
        context.saveOrLog()
        if rating.isSuccess { celebrate = true }
    }

    func nextWord() {
        guard index < targets.count - 1 else { return }
        index += 1
        repsForCurrent = 0
    }

    /// End the session, stamping its finish time and persisting the final summary.
    func finish() {
        session.endedAt = Date()
        session.refreshSummary()
        context.saveOrLog()
        finished = true
    }

    /// One-line, genuine encouragement for the summary, scaled to what actually happened.
    var summaryMessage: String {
        switch successCount {
        case 0: return "Every go counts. Showing up is the hard part — well done."
        case 1...2: return "Lovely effort. A few good goes is exactly what helps."
        default: return "Brilliant practising! Those good reps are doing real work."
        }
    }
}
