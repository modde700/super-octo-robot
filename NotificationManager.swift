import Foundation
import UserNotifications

final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    private init() {}

    @Published var status: UNAuthorizationStatus = .notDetermined

    func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
            center.getNotificationSettings { settings in
                DispatchQueue.main.async { self.status = settings.authorizationStatus }
            }
        }
    }

    /// Schedules a local notification for the given event after `delay` seconds.
    /// Uses the bundled `attention.wav` if present, otherwise the system default.
    func fire(event: EASEvent, delay: TimeInterval = 3) {
        let content = UNMutableNotificationContent()
        content.title = "Emergency Alert  •  TEST"
        content.subtitle = "\(event.code) — \(event.name)"
        content.body = event.sampleMessage

        if Bundle.main.url(forResource: "attention", withExtension: "wav") != nil {
            content.sound = UNNotificationSound(named: UNNotificationSoundName("attention.wav"))
        } else {
            content.sound = .default
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, delay), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
