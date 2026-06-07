import SwiftUI

/// How to make one speech sound: a generated mouth diagram plus original, plain-language
/// guidance (place / manner / voicing / "show your child") and example words. No licensed
/// cue artwork — everything here is drawn or written for this app.
struct PhonemeDetailView: View {
    let phoneme: Phoneme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.sp5) {
                MouthDiagram(articulator: phoneme.articulator)
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
                    .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.corner))

                VStack(alignment: .leading, spacing: Theme.sp2) {
                    Text(phoneme.label).font(.title2.bold()).foregroundStyle(Theme.label)
                    Text("Sound: /\(phoneme.ipa)/  ·  \(phoneme.kind == .vowel ? "Vowel" : "Consonant")")
                        .font(.subheadline).foregroundStyle(Theme.label2)
                }

                VStack(alignment: .leading, spacing: Theme.sp3) {
                    fact("Where", phoneme.place, "mappin.circle.fill")
                    fact("How", phoneme.manner, "waveform")
                    fact("Voice", phoneme.voicing.label, "speaker.wave.2.fill")
                }
                .padding(Theme.sp4)
                .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.corner))

                calloutCard

                VStack(alignment: .leading, spacing: Theme.sp2) {
                    Text("Example words").font(.headline).foregroundStyle(Theme.label)
                    HStack {
                        ForEach(phoneme.exampleWords, id: \.self) { word in
                            Text(word)
                                .font(.subheadline.weight(.medium))
                                .padding(.horizontal, Theme.sp3).padding(.vertical, Theme.sp2)
                                .background(Theme.brand.opacity(0.12), in: Capsule())
                                .foregroundStyle(Theme.brandInk)
                        }
                    }
                }
            }
            .frame(maxWidth: Theme.contentMaxWidth)
            .frame(maxWidth: .infinity)
            .padding(Theme.sp4)
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle(phoneme.label)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var calloutCard: some View {
        HStack(alignment: .top, spacing: Theme.sp3) {
            Image(systemName: "hand.point.up.left.fill").foregroundStyle(Theme.accent)
            VStack(alignment: .leading, spacing: Theme.sp1) {
                Text("Show your child").font(.headline).foregroundStyle(Theme.label)
                Text(phoneme.howTo).font(.subheadline).foregroundStyle(Theme.label2)
            }
        }
        .padding(Theme.sp4)
        .background(Theme.accent.opacity(0.10), in: RoundedRectangle(cornerRadius: Theme.corner))
        .accessibilityElement(children: .combine)
    }

    private func fact(_ title: String, _ value: String, _ symbol: String) -> some View {
        HStack(alignment: .top, spacing: Theme.sp3) {
            Image(systemName: symbol).foregroundStyle(Theme.brand).frame(width: 24)
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.caption.weight(.semibold)).foregroundStyle(Theme.label3)
                Text(value).font(.subheadline).foregroundStyle(Theme.label)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

/// How to make one Key Word Sign, in plain language.
struct SignDetailView: View {
    let sign: SignEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.sp5) {
                Image(systemName: sign.symbol)
                    .font(.system(size: 64))
                    .foregroundStyle(Theme.brand)
                    .frame(maxWidth: .infinity, minHeight: 140)
                    .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.corner))
                    .accessibilityHidden(true)

                Text(sign.word).font(.title2.bold()).foregroundStyle(Theme.label)

                VStack(alignment: .leading, spacing: Theme.sp3) {
                    fact("How to sign it", sign.handshape, "hand.raised.fill")
                    fact("When to use it", sign.when, "clock.fill")
                }
                .padding(Theme.sp4)
                .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.corner))

                Text("Always say the word as you sign it.")
                    .font(.footnote).foregroundStyle(Theme.label2)
            }
            .frame(maxWidth: Theme.contentMaxWidth)
            .frame(maxWidth: .infinity)
            .padding(Theme.sp4)
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle(sign.word)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func fact(_ title: String, _ value: String, _ symbol: String) -> some View {
        HStack(alignment: .top, spacing: Theme.sp3) {
            Image(systemName: symbol).foregroundStyle(Theme.brand).frame(width: 24)
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.caption.weight(.semibold)).foregroundStyle(Theme.label3)
                Text(value).font(.subheadline).foregroundStyle(Theme.label)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
