import SwiftUI
import SwiftData
import os

/// App-wide surface for save failures.
///
/// `ModelContext.saveOrLog()` logs a failed write, but a log line is invisible to a
/// parent. This shared observable lets the failure path also flag the UI: the app shell
/// observes `lastFailure` and shows one non-blocking banner. One surface for the whole
/// app, not an alert per screen.
@MainActor
@Observable
final class SaveStatus {
    static let shared = SaveStatus()

    /// The most recent unacknowledged save failure, or `nil`. Cleared on dismiss.
    var lastFailure: SaveFailure?

    func recordFailure(source: String) {
        lastFailure = SaveFailure(source: source)
    }

    func clear() { lastFailure = nil }
}

/// A single save failure, identifiable so SwiftUI can drive a banner from it.
struct SaveFailure: Identifiable, Equatable {
    let id = UUID()
    /// The function where the save failed — for support/debugging, not shown to users.
    let source: String
    let at = Date()
}

extension ModelContext {
    private static let log = Logger(subsystem: "com.adrianmcgee.speechsteps", category: "persistence")

    /// Save, and if it throws, log it and surface a banner instead of swallowing or
    /// crashing. Returns whether the save succeeded.
    @discardableResult
    func saveOrLog(_ source: String = #function) -> Bool {
        guard hasChanges else { return true }
        do {
            try save()
            return true
        } catch {
            Self.log.error("save failed in \(source, privacy: .public): \(error.localizedDescription, privacy: .public)")
            Task { @MainActor in SaveStatus.shared.recordFailure(source: source) }
            return false
        }
    }
}
