import Foundation
import UserNotifications

/// Schedules gentle "time for a quick go" nudges. The whole app is built on the evidence
/// that *a few minutes, several times a day* beats one long block — so reminders are
/// spread across the day rather than fired once. Local only; nothing leaves the device.
struct PracticeReminders {
    static let categoryID = "practice.reminder"

    /// Pleasant times to nudge, picked so even four reminders stay spread and unobtrusive.
    private static let slots: [(hour: Int, minute: Int)] =
        [(9, 0), (12, 30), (16, 0), (19, 0)]

    private static let messages = [
        "A few minutes of practice? Little and often is what helps.",
        "Quick practice break — three good goes is plenty.",
        "Time for a short, fun practice with your little one.",
        "A tiny bit of practice now keeps those words growing."
    ]

    /// Ask for permission. Returns whether it was granted.
    @discardableResult
    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        return (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
    }

    /// Replace any existing reminders with `count` daily repeating ones at spread times.
    func schedule(timesPerDay count: Int) async {
        let center = UNUserNotificationCenter.current()
        await disable()
        let n = max(1, min(count, Self.slots.count))
        for i in 0..<n {
            var components = DateComponents()
            components.hour = Self.slots[i].hour
            components.minute = Self.slots[i].minute

            let content = UNMutableNotificationContent()
            content.title = "Speech Steps"
            content.body = Self.messages[i % Self.messages.count]
            content.sound = .default
            content.categoryIdentifier = Self.categoryID

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: "\(Self.categoryID).\(i)",
                                                content: content, trigger: trigger)
            try? await center.add(request)
        }
    }

    /// Remove all scheduled practice reminders.
    func disable() async {
        let center = UNUserNotificationCenter.current()
        let ids = (0..<Self.slots.count).map { "\(Self.categoryID).\($0)" }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }
}
