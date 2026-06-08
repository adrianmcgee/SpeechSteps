import SwiftUI

/// The branded launch moment: the `TadpoleMascot` swims in, the wordmark and tagline fade up
/// beneath it, then `RootView` auto-dismisses it after a beat. Presentation-only — the
/// dismiss timer lives in `RootView` so this view stays purely visual. Reuses the shape-based
/// mascot (no bundled art) and reads only `Theme` tokens so it follows light/dark.
struct SplashView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var animateIn = false

    var body: some View {
        ZStack {
            // Opaque base so the splash fully covers what's behind it, with a soft pond
            // gradient layered on top (its lower stop is translucent on purpose).
            Theme.bg.ignoresSafeArea()
            LinearGradient(
                colors: [Theme.bg, Theme.tint(Theme.brand, 0.14)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: Theme.sp5) {
                TadpoleMascot()
                    .frame(width: 140, height: 140)
                    .scaleEffect(animateIn ? 1 : 0.6)
                    .rotationEffect(.degrees(animateIn ? 0 : -8))
                    .offset(y: animateIn ? 0 : 12)
                    .opacity(animateIn ? 1 : 0)

                VStack(spacing: Theme.sp2) {
                    Text("Tadpole Talk")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(Theme.brandInk)
                    Text("Little sounds, big steps.")
                        .font(.headline.weight(.regular))
                        .foregroundStyle(Theme.label2)
                }
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 10)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Tadpole Talk")
        .onAppear { runEntrance() }
    }

    private func runEntrance() {
        guard !reduceMotion else {
            withAnimation(.easeOut(duration: 0.4)) { animateIn = true }
            return
        }
        // Mascot springs/swims in, then the name fades up just after.
        withAnimation(.spring(response: 0.55, dampingFraction: 0.62)) { animateIn = true }
    }
}

#Preview {
    SplashView()
}
