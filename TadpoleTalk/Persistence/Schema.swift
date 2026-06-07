import Foundation
import SwiftData

/// Versioned schema so future model changes have a migration home from day one.
enum TadpoleTalkSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Child.self, WordTarget.self, PracticeSession.self, Trial.self]
    }
}

/// Migration plan placeholder — no migrations yet, but wiring it in now means adding V2
/// later is a one-line change rather than a refactor.
enum TadpoleTalkMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [TadpoleTalkSchemaV1.self] }
    static var stages: [MigrationStage] { [] }
}
