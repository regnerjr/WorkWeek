import Foundation

///
/// The constant strings used for getting values in and out of NSUserDefaults
///
public enum SettingsKey: String {
    case HoursInWorkWeek = "hoursInWorkWeekPrefKey"
    case ResetDay        = "resetDayPrefKey"
    case ResetHour       = "resetHourPrefKey"
    case WorkRadius      = "workRadiusPrefKey"
    case ClearDate       = "clearDate"
    case OnboardingComplete = "onboardingComplete"
}

///
/// A simpler way to access the NSUserDefaults.StandardUserDefaults()
/// Purely a convenience.
///
public struct Defaults {
    public static let standard = UserDefaults.standard
}

// Wish I could break up the settings keys into classes which would constrain this so only the
// strings which control the double settings could be passes to doubleForKey
extension UserDefaults {
    public func doubleForKey(_ defaultName: SettingsKey) -> Double {
        return double(forKey: defaultName.rawValue)
    }
    public func setDouble(_ value: Double, forKey defaultName: SettingsKey) {
        set(value, forKey: defaultName.rawValue)
    }
    public func integerForKey(_ defaultName: SettingsKey) -> Int {
        return integer(forKey: defaultName.rawValue)
    }
    public func setInteger(_ value: Int, forKey defaultName: SettingsKey) {
        set(value, forKey: defaultName.rawValue)
    }
    public func set(_ object: Any?, forKey key: SettingsKey) {
        set(object, forKey: key.rawValue)
    }
    public func objectForKey(_ defaultName: SettingsKey) -> Any? {
        return object(forKey: defaultName.rawValue) as Any?
    }
    public func setBool(_ value: Bool, forKey defaultName: SettingsKey) {
        set(value, forKey: defaultName.rawValue)
    }
    public func boolForKey(_ defaultName: SettingsKey) -> Bool {
        return bool(forKey: defaultName.rawValue)
    }
    public func registerDefaults(_ defaults: [SettingsKey: Any]) {
        var typedDefaults = [String: Any]()
        for (name, item) in defaults {
            typedDefaults[name.rawValue] = item
        }
        self.register(defaults: typedDefaults)
    }
}

public func updateDefaultResetDate( _ defaults: UserDefaults = Defaults.standard) {
    let date = getDateForReset(defaults.integerForKey(.ResetDay),
                               hour: defaults.integerForKey(.ResetHour), minute: 0)
    defaults.set(date, forKey: .ClearDate)
}
