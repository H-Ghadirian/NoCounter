import Foundation

struct NoStore {
    private static let suite: UserDefaults = {
        if let suite = UserDefaults(suiteName: "group.me.HamedGh.NoCounter") {
            return suite
        }
        #if DEBUG
        print("NoStore: App Group not available, falling back to standard defaults.")
        #endif
        return .standard
    }()

    private static let key = "no_count"

    static func increment() {
        let current = suite.integer(forKey: key)
        suite.set(current + 1, forKey: key)
    }

    static func decrement() {
        let current = suite.integer(forKey: key)
        suite.set(max(0, current - 1), forKey: key)
    }

    static func count() -> Int {
        suite.integer(forKey: key)
    }

    static func reset() {
        set(0)
    }

    static func set(_ value: Int) {
        suite.set(max(0, value), forKey: key)
    }
}
