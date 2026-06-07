import Foundation
import SwiftData

/// A single practice attempt: which word, how it went, when. The grain the SLP report and
/// progress charts are built from.
@Model
final class Trial {
    var targetText: String = ""
    var ratingRaw: String = TrialRating.correct.rawValue
    var timestamp: Date = Date()

    var session: PracticeSession?

    init(targetText: String, rating: TrialRating, timestamp: Date = Date()) {
        self.targetText = targetText
        self.ratingRaw = rating.rawValue
        self.timestamp = timestamp
    }

    var rating: TrialRating {
        get { TrialRating(rawValue: ratingRaw) ?? .tryAgain }
        set { ratingRaw = newValue.rawValue }
    }
}
