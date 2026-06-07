import SwiftUI

/// A gentle reminder of the DTTC-style cueing ladder: give lots of support, then fade it as
/// your child succeeds. Collapsed by default so it coaches without cluttering the session.
struct CueLadderView: View {
    @State private var expanded = false

    private let steps: [(String, String)] = [
        ("1", "Say it together — slowly, at the same time, so they can copy your mouth."),
        ("2", "Let them try right after you, with a little less help."),
        ("3", "Fade your help as they get it — just a mouthed shape or first sound."),
        ("4", "Play with it — whisper it, sing it, say it in a silly voice.")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.sp2) {
            Button {
                withAnimation(.easeInOut) { expanded.toggle() }
            } label: {
                HStack {
                    Image(systemName: "stairs")
                    Text("How much help?").font(.subheadline.weight(.medium))
                    Spacer()
                    Image(systemName: expanded ? "chevron.up" : "chevron.down").font(.caption)
                }
                .foregroundStyle(Theme.brandInk)
            }

            if expanded {
                VStack(alignment: .leading, spacing: Theme.sp2) {
                    ForEach(steps, id: \.0) { step in
                        HStack(alignment: .top, spacing: Theme.sp2) {
                            Text(step.0)
                                .font(.caption.bold()).foregroundStyle(Theme.onColor)
                                .frame(width: 20, height: 20)
                                .background(Theme.brand, in: Circle())
                            Text(step.1).font(.caption).foregroundStyle(Theme.label2)
                        }
                    }
                }
                .padding(.top, Theme.sp1)
            }
        }
        .padding(Theme.sp3)
        .background(Theme.brand.opacity(0.10), in: RoundedRectangle(cornerRadius: Theme.cornerSm))
        .accessibilityElement(children: .contain)
    }
}
