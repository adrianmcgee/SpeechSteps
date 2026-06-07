import SwiftUI

/// Shown once before anything else. Speech Steps supports therapy a speech pathologist
/// directs — it does not diagnose or replace them — and the parent acknowledges that here.
struct DisclaimerView: View {
    @AppStorage("hasAcceptedDisclaimer") private var hasAcceptedDisclaimer = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.sp5) {
                VStack(alignment: .leading, spacing: Theme.sp3) {
                    Image(systemName: "bubble.left.and.text.bubble.right.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(Theme.brand)
                    Text("Welcome to Speech Steps")
                        .font(.largeTitle.bold())
                        .foregroundStyle(Theme.label)
                    Text("A calm companion for families practising at home between speech therapy sessions.")
                        .font(.title3)
                        .foregroundStyle(Theme.label2)
                }

                VStack(alignment: .leading, spacing: Theme.sp4) {
                    point("hand.raised.fill",
                          "A support, not a substitute",
                          "This app helps you practise the targets your speech pathologist gives you. It does not diagnose, assess, or replace professional therapy.")
                    point("lock.fill",
                          "Private by design",
                          "Everything you record stays on this device. No account, no tracking, nothing uploaded.")
                    point("heart.fill",
                          "Follow your therapist's lead",
                          "Always check new targets and techniques with your speech pathologist. When in doubt, ask them.")
                }
                .padding(Theme.sp4)
                .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.corner))

                Button {
                    hasAcceptedDisclaimer = true
                } label: {
                    Text("I understand — let's begin")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: Theme.btnHeight)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier(A11y.disclaimerAccept)
            }
            .frame(maxWidth: Theme.contentMaxWidth)
            .frame(maxWidth: .infinity)
            .padding(Theme.sp5)
        }
        .background(Theme.bg.ignoresSafeArea())
    }

    private func point(_ symbol: String, _ title: String, _ body: String) -> some View {
        HStack(alignment: .top, spacing: Theme.sp3) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(Theme.brand)
                .frame(width: 32)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: Theme.sp1) {
                Text(title).font(.headline).foregroundStyle(Theme.label)
                Text(body).font(.subheadline).foregroundStyle(Theme.label2)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
