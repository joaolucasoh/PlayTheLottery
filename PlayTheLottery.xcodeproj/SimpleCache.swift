import Foundation

struct SimpleCache {
    static func save<T: Encodable>(_ value: T, forKey key: String) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(value) {
            UserDefaults.standard.set(data, forKey: key)
            UserDefaults.standard.set(Date(), forKey: key + ":lastUpdated")
        }
    }

    static func load<T: Decodable>(_ type: T.Type, forKey key: String) -> (data: T, lastUpdated: Date)? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        guard let decoded = try? decoder.decode(T.self, from: data) else { return nil }
        let last = UserDefaults.standard.object(forKey: key + ":lastUpdated") as? Date ?? Date.distantPast
        return (decoded, last)
    }

    static func shouldRefresh(lastUpdated: Date, calendar: Calendar = .current, now: Date = Date()) -> Bool {
        // Refresh if it's a different day OR after 22:00 local time and last update was before 22:00 today
        let startOfToday = calendar.startOfDay(for: now)
        if lastUpdated < startOfToday { return true }
        let comps = calendar.dateComponents([.year, .month, .day], from: now)
        var at22 = DateComponents()
        at22.year = comps.year
        at22.month = comps.month
        at22.day = comps.day
        at22.hour = 22
        at22.minute = 0
        at22.second = 0
        if let tenPM = calendar.date(from: at22) {
            // if now is after 22:00 and lastUpdated is before 22:00 today, refresh
            if now >= tenPM && lastUpdated < tenPM { return true }
        }
        return false
    }
}
