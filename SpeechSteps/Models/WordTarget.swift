import Foundation
import SwiftData

/// A word (or syllable) the family is practising. Seeded from a starter bank organised by
/// syllable shape, then fully editable — the SLP typically gives a handful of targets per
/// week and the parent marks those active.
@Model
final class WordTarget {
    var text: String = ""
    /// Stored as the enum raw value so SwiftData stays happy; accessed via `shape`.
    var shapeRaw: String = SyllableShape.cv.rawValue
    /// IDs into the bundled phoneme reference, so a target can link to its sounds.
    var phonemeIDs: [String] = []
    /// Whether this is part of the current week's focus set.
    var isActiveThisWeek: Bool = false
    var notes: String = ""
    var createdAt: Date = Date()

    var child: Child?

    init(text: String,
         shape: SyllableShape,
         phonemeIDs: [String] = [],
         isActiveThisWeek: Bool = false,
         notes: String = "") {
        self.text = text
        self.shapeRaw = shape.rawValue
        self.phonemeIDs = phonemeIDs
        self.isActiveThisWeek = isActiveThisWeek
        self.notes = notes
        self.createdAt = Date()
    }

    var shape: SyllableShape {
        get { SyllableShape(rawValue: shapeRaw) ?? .other }
        set { shapeRaw = newValue.rawValue }
    }
}
