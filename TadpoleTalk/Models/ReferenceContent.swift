import Foundation

/// A speech sound in the reference library. Shipped as bundled, read-only data with
/// **original** descriptive content (place / manner / voicing + example words) and an
/// in-app generated mouth diagram — no licensed cue artwork. A parent may later attach
/// their own recorded demo clip, keyed by `id`.
struct Phoneme: Codable, Identifiable, Hashable {
    let id: String          // e.g. "p", "b", "ah"
    let ipa: String         // IPA symbol shown to parents who want it
    let label: String       // friendly name, e.g. "p as in pig"
    let kind: Kind
    let place: String       // where in the mouth, plain language
    let manner: String      // how the sound is made
    let voicing: Voicing
    let howTo: String       // a parent-friendly "show your child" instruction
    let exampleWords: [String]
    /// Drives the generated mouth diagram (lips / tongue-tip / back / open).
    let articulator: Articulator

    enum Kind: String, Codable { case consonant, vowel }
    enum Voicing: String, Codable {
        case voiced, voiceless
        var label: String { self == .voiced ? "Voice on (throat buzzes)" : "Voice off (quiet)" }
    }
    enum Articulator: String, Codable { case lips, tongueTip, tongueBack, open, rounded }
}

/// A Key Word Sign entry. Signs are a *bridge to* speech, not a replacement. Shipped with
/// an **original** plain-language handshape description (no Auslan video / licensed
/// imagery); a parent can attach their own recorded demo, keyed by `id`.
struct SignEntry: Codable, Identifiable, Hashable {
    let id: String          // e.g. "more"
    let word: String        // "More"
    let category: String    // "Mealtime", "Core words", ...
    let handshape: String   // how to make the sign, plain language
    let when: String        // when you'd use it
    let symbol: String      // SF Symbol used as a friendly icon
}

/// A pre-built practice target the parent can add with one tap, organised by syllable
/// shape so the starter bank already follows the CAS difficulty progression.
struct StarterTarget: Codable, Identifiable, Hashable {
    var id: String { text }
    let text: String
    let shape: SyllableShape
    let phonemeIDs: [String]
}
