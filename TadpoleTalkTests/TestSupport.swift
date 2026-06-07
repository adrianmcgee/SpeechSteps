import XCTest
import SwiftData
@testable import TadpoleTalk

/// Shared helpers for the unit tests: an isolated in-memory store and a few builders so
/// each test starts from a clean, known state without touching real on-device data.
enum TestSupport {
    @MainActor
    static func makeContext() throws -> ModelContext {
        let schema = Schema(versionedSchema: TadpoleTalkSchemaV1.self)
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        return ModelContext(container)
    }

    @MainActor
    @discardableResult
    static func makeChild(in context: ModelContext, name: String = "Mia") -> Child {
        let child = Child(name: name)
        context.insert(child)
        return child
    }

    /// Log a finished session of trials on a given day.
    @MainActor
    static func addSession(to child: Child, in context: ModelContext,
                           on day: Date, ratings: [TrialRating]) {
        let session = PracticeSession(startedAt: day)
        session.child = child
        context.insert(session)
        for rating in ratings {
            let trial = Trial(targetText: "more", rating: rating, timestamp: day)
            trial.session = session
            context.insert(trial)
            session.trials.append(trial)
        }
        session.endedAt = day
        session.refreshSummary()
        try? context.save()
    }
}
