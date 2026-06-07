import SwiftUI
import SwiftData

@main
struct TadpoleTalkApp: App {
    @State private var persistence = PersistenceController()

    init() {
        // UI tests launch with `-localStore` for a throwaway in-memory store; reset the
        // one persisted flag (the disclaimer acknowledgement) too so each run starts at
        // the true first-launch state. `-localStore` only resets SwiftData otherwise.
        if ProcessInfo.processInfo.arguments.contains("-localStore") {
            UserDefaults.standard.removeObject(forKey: "hasAcceptedDisclaimer")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(persistence)
                .environment(SaveStatus.shared)
                .tint(Theme.brand)
        }
        .modelContainer(persistence.container)
    }
}
