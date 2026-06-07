import SwiftUI

/// The shape of a word by consonant (C) / vowel (V) structure. In CAS therapy targets
/// are selected and sequenced by syllable shape and movement complexity — not by
/// phoneme alone — so this is a first-class property of every target.
enum SyllableShape: String, Codable, CaseIterable, Identifiable {
    case cv      // "bee", "go"
    case vc      // "up", "egg"
    case cvc     // "cat", "dog"
    case cvcv    // "baby", "mama"
    case cvcvc   // "banana"-ish chunks, "rabbit"
    case other   // clusters, longer words

    var id: String { rawValue }

    /// Short label as therapists write it.
    var code: String {
        switch self {
        case .cv: return "CV"
        case .vc: return "VC"
        case .cvc: return "CVC"
        case .cvcv: return "CVCV"
        case .cvcvc: return "CVCVC"
        case .other: return "Other"
        }
    }

    var title: String {
        switch self {
        case .cv: return "Consonant + vowel"
        case .vc: return "Vowel + consonant"
        case .cvc: return "Consonant + vowel + consonant"
        case .cvcv: return "Two simple syllables"
        case .cvcvc: return "Longer / multisyllable"
        case .other: return "Clusters & longer words"
        }
    }

    var example: String {
        switch self {
        case .cv: return "bee, go, more"
        case .vc: return "up, egg, on"
        case .cvc: return "cat, dog, cup"
        case .cvcv: return "mama, baby, water"
        case .cvcvc: return "rabbit, banana"
        case .other: return "stop, spoon, elephant"
        }
    }

    /// Rough difficulty order, easiest first — used to sort the target bank.
    var order: Int {
        switch self {
        case .cv: return 0
        case .vc: return 1
        case .cvc: return 2
        case .cvcv: return 3
        case .cvcvc: return 4
        case .other: return 5
        }
    }
}

/// How a single practice attempt (a "trial") went. CAS practice prizes successful
/// repetitions over volume, so the model is deliberately three simple buckets a parent
/// can tap without judgement, not a fine-grained score.
enum TrialRating: String, Codable, CaseIterable, Identifiable {
    case correct   // said it well
    case approx    // close — a good attempt
    case tryAgain  // not yet — move on, stay positive

    var id: String { rawValue }

    var title: String {
        switch self {
        case .correct: return "Got it!"
        case .approx: return "Close"
        case .tryAgain: return "Try again"
        }
    }

    var symbol: String {
        switch self {
        case .correct: return "star.fill"
        case .approx: return "hand.thumbsup.fill"
        case .tryAgain: return "arrow.clockwise"
        }
    }

    var color: Color {
        switch self {
        case .correct: return Theme.correct
        case .approx: return Theme.approx
        case .tryAgain: return Theme.tryAgain
        }
    }

    /// Counts toward "successful reps" — the number that actually drives motor learning.
    var isSuccess: Bool { self == .correct }
}
