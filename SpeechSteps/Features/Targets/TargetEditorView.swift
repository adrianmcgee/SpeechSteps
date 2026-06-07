import SwiftUI
import SwiftData

/// Add or edit a practice word: its text, syllable shape, the sounds it focuses on, an
/// optional note from the SLP, and whether it's in this week's set.
struct TargetEditorView: View {
    let child: Child
    var existing: WordTarget?
    let onClose: () -> Void

    @Environment(\.modelContext) private var context
    @State private var vm = TargetsViewModel()

    @State private var text: String = ""
    @State private var shape: SyllableShape = .cv
    @State private var notes: String = ""
    @State private var activeThisWeek: Bool = true
    @State private var phonemeIDs: Set<String> = []

    private let allPhonemes = ContentStore.shared.phonemes

    var body: some View {
        NavigationStack {
            Form {
                Section("Word") {
                    TextField("e.g. more", text: $text)
                        .textInputAutocapitalization(.never)
                        .accessibilityIdentifier(A11y.targetText)
                }
                Section("Sound shape") {
                    Picker("Shape", selection: $shape) {
                        ForEach(SyllableShape.allCases) { s in
                            Text("\(s.code) · \(s.example)").tag(s)
                        }
                    }
                    .accessibilityIdentifier(A11y.targetShape)
                }
                Section("Focus sounds (optional)") {
                    ForEach(allPhonemes) { p in
                        Button {
                            if phonemeIDs.contains(p.id) { phonemeIDs.remove(p.id) }
                            else { phonemeIDs.insert(p.id) }
                        } label: {
                            HStack {
                                Text(p.label).foregroundStyle(Theme.label)
                                Spacer()
                                if phonemeIDs.contains(p.id) {
                                    Image(systemName: "checkmark").foregroundStyle(Theme.brand)
                                }
                            }
                        }
                        .accessibilityAddTraits(phonemeIDs.contains(p.id) ? [.isSelected] : [])
                    }
                }
                Section("Note from your therapist (optional)") {
                    TextField("e.g. focus on the final sound", text: $notes, axis: .vertical)
                }
                Section {
                    Toggle("Practise this week", isOn: $activeThisWeek)
                        .accessibilityIdentifier(A11y.targetActive)
                }
            }
            .navigationTitle(existing == nil ? "New word" : "Edit word")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onClose)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
                        .accessibilityIdentifier(A11y.targetSave)
                }
            }
            .onAppear(perform: loadExisting)
        }
    }

    private func loadExisting() {
        guard let existing else { return }
        text = existing.text
        shape = existing.shape
        notes = existing.notes
        activeThisWeek = existing.isActiveThisWeek
        phonemeIDs = Set(existing.phonemeIDs)
    }

    private func save() {
        if let existing {
            existing.text = text.trimmingCharacters(in: .whitespaces)
            existing.shape = shape
            existing.notes = notes
            existing.isActiveThisWeek = activeThisWeek
            existing.phonemeIDs = Array(phonemeIDs)
            vm.save(in: context)
        } else {
            vm.add(text: text, shape: shape, phonemeIDs: Array(phonemeIDs),
                   notes: notes, activeThisWeek: activeThisWeek, to: child, in: context)
        }
        onClose()
    }
}
