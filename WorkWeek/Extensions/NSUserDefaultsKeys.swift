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
    public static let standard = NSUserDefaults.standardUserDefaults()
}

// Wish I could break up the settings keys into classes which would constrain this so only the
// strings which control the double settings could be passes to doubleForKey
extension NSUserDefaults {
    public func doubleForKey(defaultName: SettingsKey) -> Double {
        return doubleForKey(defaultName.rawValue)
    }
    public func setDouble(value: Double, forKey defaultName: SettingsKey) {
        setDouble(value, forKey: defaultName.rawValue)
    }
    public func integerForKey(defaultName: SettingsKey) -> Int {
        return integerForKey(defaultName.rawValue)
    }
    public func setInteger(value: Int, forKey defaultName: SettingsKey) {
        setInteger(value, forKey: defaultName.rawValue)
    }
    public func setObject(object: AnyObject, forKey key: SettingsKey) {
        setObject(object, forKey: key.rawValue)
    }
    public func objectForKey(defaultName: SettingsKey) -> AnyObject? {
        return objectForKey(defaultName.rawValue)
    }
    public func setBool(value: Bool, forKey defaultName: SettingsKey) {
        setBool(value, forKey: defaultName.rawValue)
    }
    public func boolForKey(defaultName: SettingsKey) -> Bool {
        return boolForKey(defaultName.rawValue)
    }
}


public func updateDefaultResetDate( defaults: NSUserDefaults = Defaults.standard) {
    let date = getDateForReset(defaults.integerForKey(.ResetDay),
        hour: defaults.integerForKey(.ResetHour), minute: 0)
    defaults.setObject(date, forKey: .ClearDate)
}
