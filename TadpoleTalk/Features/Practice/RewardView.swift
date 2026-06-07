import SwiftUI

/// A brief, joyful burst shown when a child gets a word — the reward moment that keeps a
/// young child motivated. Pure SF Symbols (never emoji, which render as tofu boxes in the
/// simulator) and SwiftUI animation, so it's crisp, accessible, and ships no assets.
struct RewardBurst: View {
    /// Toggled by the session each time a success is logged.
    @Binding var trigger: Bool

    @State private var bursts: [Burst] = []

    private struct Burst: Identifiable {
        let id = UUID()
        let symbol: String
        let angle: Double
        let distance: CGFloat
        let tint: Color
    }

    private let symbols = ["star.fill", "sparkle", "heart.fill", "party.popper.fill", "hands.clap.fill"]
    private let tints = [Theme.accent, Theme.correct, Theme.pink, Theme.brand, Theme.purple]

    var body: some View {
        ZStack {
            ForEach(bursts) { burst in
                Image(systemName: burst.symbol)
                    .font(.title)
                    .foregroundStyle(burst.tint)
                    .modifier(FlyAway(angle: burst.angle, distance: burst.distance))
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onChange(of: trigger) { _, newValue in
            if newValue { fire() }
        }
    }

    private func fire() {
        let new = (0..<10).map { i in
            Burst(symbol: symbols[i % symbols.count],
                  angle: Double(i) / 10 * 360 + Double.random(in: -16...16),
                  distance: CGFloat.random(in: 90...170),
                  tint: tints[i % tints.count])
        }
        bursts = new
        // Clear after the animation so the next success starts fresh.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            bursts = []
            trigger = false
        }
    }
}

/// Animates a symbol outward from the centre while fading and spinning a little.
private struct FlyAway: ViewModifier, Animatable {
    let angle: Double
    let distance: CGFloat
    @State private var progress: CGFloat = 0

    func body(content: Content) -> some View {
        let rad = angle * .pi / 180
        content
            .offset(x: cos(rad) * distance * progress, y: sin(rad) * distance * progress)
            .opacity(Double(1 - progress))
            .scaleEffect(0.6 + progress * 0.8)
            .onAppear {
                withAnimation(.easeOut(duration: 0.9)) { progress = 1 }
            }
    }
}
