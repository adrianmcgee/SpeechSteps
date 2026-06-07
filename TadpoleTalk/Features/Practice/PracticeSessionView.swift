import SwiftUI
import SwiftData

/// The core of the app: a short, parent-led practice session. One word at a time, with a
/// reminder of how to make it, a cueing-ladder prompt, three simple ways to log how it
/// went, and a celebration when the child gets it. Ends on a warm summary.
struct PracticeSessionView: View {
    let child: Child
    let targets: [WordTarget]

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var vm: PracticeSessionViewModel?
    @State private var howToPhoneme: Phoneme?

    var body: some View {
        Group {
            if let vm {
                if vm.finished {
                    SessionSummaryView(vm: vm) { dismiss() }
                } else {
                    sessionBody(vm)
                }
            } else {
                Color.clear
            }
        }
        .onAppear {
            if vm == nil {
                vm = PracticeSessionViewModel(child: child, targets: targets, context: context)
            }
        }
    }

    private func sessionBody(_ vm: PracticeSessionViewModel) -> some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: Theme.sp4) {
                topBar(vm)
                ScrollView {
                    VStack(spacing: Theme.sp4) {
                        wordCard(vm)
                        CueLadderView()
                        ratingButtons(vm)
                    }
                    .frame(maxWidth: Theme.contentMaxWidth)
                    .frame(maxWidth: .infinity)
                    .padding(Theme.sp4)
                }
                advanceBar(vm)
            }

            RewardBurst(trigger: Binding(
                get: { vm.celebrate },
                set: { vm.celebrate = $0 }
            ))
        }
        .sheet(item: $howToPhoneme) { phoneme in
            NavigationStack {
                PhonemeDetailView(phoneme: phoneme)
            }
        }
    }

    private func topBar(_ vm: PracticeSessionViewModel) -> some View {
        HStack {
            Button { vm.finish() } label: {
                Image(systemName: "xmark.circle.fill").font(.title2).foregroundStyle(Theme.label3)
            }
            .accessibilityLabel("End practice")
            Spacer()
            Text(vm.progressText).font(.subheadline.weight(.medium)).foregroundStyle(Theme.label2)
            Spacer()
            Label("\(vm.successCount)", systemImage: "star.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.accent)
                .accessibilityLabel("\(vm.successCount) great reps")
        }
        .padding(.horizontal, Theme.sp4)
        .padding(.top, Theme.sp4)
    }

    private func wordCard(_ vm: PracticeSessionViewModel) -> some View {
        VStack(spacing: Theme.sp3) {
            if let phoneme = vm.currentPhoneme() {
                MouthDiagram(phoneme: phoneme, style: .standard, animated: true).frame(height: 120)
                Button {
                    howToPhoneme = phoneme
                } label: {
                    Label("How to make this sound", systemImage: "info.circle")
                        .font(.subheadline.weight(.medium))
                }
                .foregroundStyle(Theme.brandInk)
            }
            Text(vm.currentTarget?.text ?? "")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.label)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .accessibilityIdentifier("practice.word")
            if let shape = vm.currentTarget?.shape {
                Text(shape.code).font(.caption.weight(.semibold))
                    .padding(.horizontal, Theme.sp2).padding(.vertical, 4)
                    .background(Theme.brand.opacity(0.14), in: Capsule())
                    .foregroundStyle(Theme.brandInk)
            }
            if let notes = vm.currentTarget?.notes, !notes.isEmpty {
                Text(notes).font(.subheadline).foregroundStyle(Theme.label2)
                    .multilineTextAlignment(.center)
            }
            if vm.repsForCurrent > 0 {
                Text("\(vm.repsForCurrent) tr\(vm.repsForCurrent == 1 ? "y" : "ies") this word")
                    .font(.caption).foregroundStyle(Theme.label3)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.sp5)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.corner))
    }

    private func ratingButtons(_ vm: PracticeSessionViewModel) -> some View {
        HStack(spacing: Theme.sp3) {
            ratingButton(.correct, A11y.practiceRatingCorrect, vm)
            ratingButton(.approx, A11y.practiceRatingApprox, vm)
            ratingButton(.tryAgain, A11y.practiceRatingTryAgain, vm)
        }
    }

    private func ratingButton(_ rating: TrialRating, _ id: String, _ vm: PracticeSessionViewModel) -> some View {
        Button {
            vm.log(rating)
        } label: {
            VStack(spacing: Theme.sp2) {
                Image(systemName: rating.symbol).font(.title)
                Text(rating.title).font(.subheadline.weight(.semibold))
            }
            .frame(maxWidth: .infinity, minHeight: Theme.bigButton)
            .foregroundStyle(rating.color)
            .background(rating.color.opacity(0.14), in: RoundedRectangle(cornerRadius: Theme.corner))
        }
        .accessibilityIdentifier(id)
    }

    private func advanceBar(_ vm: PracticeSessionViewModel) -> some View {
        HStack {
            if vm.isLastTarget {
                Button { vm.finish() } label: {
                    Text("Finish").font(.headline).frame(maxWidth: .infinity, minHeight: Theme.btnHeight)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier(A11y.practiceDone)
            } else {
                Button { vm.nextWord() } label: {
                    HStack { Text("Next word"); Image(systemName: "arrow.right") }
                        .font(.headline).frame(maxWidth: .infinity, minHeight: Theme.btnHeight)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier(A11y.practiceNext)
            }
        }
        .frame(maxWidth: Theme.contentMaxWidth)
        .frame(maxWidth: .infinity)
        .padding(Theme.sp4)
    }
}

/// Warm end-of-session screen — celebrate the effort, show the simple tally, get out.
private struct SessionSummaryView: View {
    let vm: PracticeSessionViewModel
    let onDone: () -> Void

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: Theme.sp5) {
                TadpoleMascot()
                    .frame(width: 120, height: 120)
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 84)).foregroundStyle(Theme.accent)
                Text("Great practising!").font(.largeTitle.bold()).foregroundStyle(Theme.label)
                Text(vm.summaryMessage).font(.title3).foregroundStyle(Theme.label2)
                    .multilineTextAlignment(.center)

                HStack(spacing: Theme.sp4) {
                    tally("\(vm.successCount)", "great reps", Theme.correct)
                    tally("\(vm.totalCount)", "tries", Theme.brand)
                }

                Button(action: onDone) {
                    Text("Done").font(.headline).frame(maxWidth: .infinity, minHeight: Theme.btnHeight)
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: Theme.contentMaxWidth)
            .frame(maxWidth: .infinity)
            .padding(Theme.sp5)
        }
        .accessibilityIdentifier(A11y.practiceSummary)
    }

    private func tally(_ value: String, _ label: String, _ color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.system(size: 40, weight: .bold, design: .rounded)).foregroundStyle(color)
            Text(label).font(.caption).foregroundStyle(Theme.label2)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.sp4)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.corner))
        .accessibilityElement(children: .combine)
    }
}
