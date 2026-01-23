import UserNotifications

enum NotificationsManager {
    static func requestAuthorization() async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: granted)
                }
            }
        }
    }

    static func clearScheduledNotifications(prefix: String = "contest-reminder-") {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let identifiersToRemove = requests
                .filter { $0.identifier.hasPrefix(prefix) }
                .map { $0.identifier }
            center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        }
    }

    static func scheduleDailyContestReminders(for date: Date, minPrizeText: String?, maxPrizeText: String?) {
        let twelvePM = dateSettingTime(date, hour: 12, minute: 0)
        let fourPM = dateSettingTime(date, hour: 16, minute: 0)
        let sevenPM = dateSettingTime(date, hour: 19, minute: 0)

        let center = UNUserNotificationCenter.current()
        clearScheduledNotifications()

        scheduleOneTimeNotification(
            identifier: "contest-reminder-12",
            date: twelvePM,
            title: "Já fez sua fezinha hoje?",
            body: "As apostas se encerram às 20h."
        )

        let body16: String
        if let min = minPrizeText, let max = maxPrizeText {
            body16 = "Os prêmios hoje estão entre \(min) e \(max) de reais."
        } else {
            body16 = "Os prêmios de hoje estão disponíveis. Boa sorte!"
        }

        scheduleOneTimeNotification(
            identifier: "contest-reminder-16",
            date: fourPM,
            title: "Vai quê, né?",
            body: body16
        )

        scheduleOneTimeNotification(
            identifier: "contest-reminder-19",
            date: sevenPM,
            title: "Já fez sua fezinha hoje?",
            body: "As apostas se encerram às 20h."
        )
    }

    private static func scheduleOneTimeNotification(identifier: String, date: Date, title: String, body: String) {
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        center.add(request)
    }

    private static func dateSettingTime(_ date: Date, hour: Int, minute: Int) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        components.minute = minute
        components.second = 0
        return Calendar.current.date(from: components) ?? date
    }
}
