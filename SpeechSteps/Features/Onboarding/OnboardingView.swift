import SwiftUI
import SwiftData

/// First-run profile creation. One screen: who are we practising with? Seeds a starter
/// target bank so the app is useful immediately.
struct OnboardingView: View {
    @Environment(\.modelContext) private var context
    @State private var vm = OnboardingViewModel()

    private let avatars = ["teddybear.fill", "hare.fill", "bird.fill", "tortoise.fill",
                           "cat.fill", "dog.fill", "ladybug.fill", "fish.fill"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.sp6) {
                VStack(alignment: .leading, spacing: Theme.sp2) {
                    Text("Let's set up").font(.largeTitle.bold()).foregroundStyle(Theme.label)
                    Text("Tell us a little about your child so we can personalise things.")
                        .font(.title3).foregroundStyle(Theme.label2)
                }

                field("Their name") {
                    TextField("e.g. Mia", text: $vm.name)
                        .textInputAutocapitalization(.words)
                        .padding(Theme.sp3)
                        .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.cornerSm))
                        .accessibilityIdentifier(A11y.onboardingName)
                }

                field("Age") {
                    Stepper(value: $vm.ageMonths, in: 12...144, step: 1) {
                        Text(vm.ageDescription).foregroundStyle(Theme.label)
                    }
                    .accessibilityIdentifier(A11y.onboardingAge)
                }

                field("Pick a friendly avatar") {
                    LazyVGrid(columns: Theme.adaptiveColumns(min: 60), spacing: Theme.sp3) {
                        ForEach(avatars, id: \.self) { symbol in
                            Button { vm.avatarSymbol = symbol } label: {
                                Image(systemName: symbol)
                                    .font(.title)
                                    .frame(maxWidth: .infinity, minHeight: 60)
                                    .background(vm.avatarSymbol == symbol ? Theme.brand.opacity(0.18) : Theme.card,
                                                in: RoundedRectangle(cornerRadius: Theme.cornerSm))
                                    .foregroundStyle(vm.avatarSymbol == symbol ? Theme.brand : Theme.label2)
                            }
                            .accessibilityLabel(symbol)
                            .accessibilityAddTraits(vm.avatarSymbol == symbol ? [.isSelected] : [])
                        }
                    }
                }

                Button {
                    vm.createChild(in: context)
                } label: {
                    Text("Start practising")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: Theme.btnHeight)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!vm.canContinue)
                .accessibilityIdentifier(A11y.onboardingContinue)
            }
            .frame(maxWidth: Theme.contentMaxWidth)
            .frame(maxWidth: .infinity)
            .padding(Theme.sp5)
        }
        .background(Theme.bg.ignoresSafeArea())
    }

    private func field<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Theme.sp2) {
            Text(label).font(.headline).foregroundStyle(Theme.label)
            content()
        }
    }
}
