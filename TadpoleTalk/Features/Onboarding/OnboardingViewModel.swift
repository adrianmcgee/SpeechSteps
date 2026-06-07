import SwiftUI
import SwiftData

/// Holds the new-profile form state and the logic to create the child plus seed a starter
/// target bank. Kept out of the view so the seeding rule is unit-testable.
@Observable
final class OnboardingViewModel {
    var name: String = ""
    var ageMonths: Int = 36
    var avatarSymbol: String = "teddybear.fill"

    var canContinue: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    var ageDescription: String {
        let years = ageMonths / 12
        let months = ageMonths % 12
        switch (years, months) {
        case (0, _): return "\(months) months"
        case (_, 0): return years == 1 ? "1 year" : "\(years) years"
        default: return "\(years)y \(months)m"
        }
    }

    /// Create the child and seed an initial target bank from the bundled starter list.
    /// The first few easy CV targets are marked active so Today isn't empty on day one.
    func createChild(in context: ModelContext, content: ContentStore = .shared) {
        let child = Child(name: name.trimmingCharacters(in: .whitespaces),
                          ageMonths: ageMonths, avatarSymbol: avatarSymbol)
        context.insert(child)

        for (index, starter) in content.starterTargets.enumerated() {
            let target = WordTarget(text: starter.text, shape: starter.shape,
                                    phonemeIDs: starter.phonemeIDs,
                                    isActiveThisWeek: starter.shape == .cv && index < 3)
            target.child = child
            context.insert(target)
        }
        context.saveOrLog()
    }
}
