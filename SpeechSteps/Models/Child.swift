import Foundation
import SwiftData

/// The child the app is supporting. Single-child in v1, but modelled as a record so a
/// future version can hold siblings. All data hangs off this and is local-only.
@Model
final class Child {
    var name: String = ""
    /// Age in months — finer than years for a toddler, and used only to personalise copy.
    var ageMonths: Int = 36
    /// SF Symbol name used as a friendly avatar (no photo needed, no PII).
    var avatarSymbol: String = "teddybear.fill"
    var createdAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \WordTarget.child)
    var targets: [WordTarget] = []

    @Relationship(deleteRule: .cascade, inverse: \PracticeSession.child)
    var sessions: [PracticeSession] = []

    init(name: String = "", ageMonths: Int = 36, avatarSymbol: String = "teddybear.fill") {
        self.name = name
        self.ageMonths = ageMonths
        self.avatarSymbol = avatarSymbol
        self.createdAt = Date()
    }

    /// Targets the parent has marked for this week's focus, easiest shape first.
    var activeTargets: [WordTarget] {
        targets.filter(\.isActiveThisWeek).sorted { $0.shape.order < $1.shape.order }
    }
}
