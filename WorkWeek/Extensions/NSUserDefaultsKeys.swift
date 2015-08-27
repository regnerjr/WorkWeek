import Foundation

///
/// The constant strings used for getting values in and out of NSUserDefaults
///
public enum SettingsKey : String{

    /// Hours in a Work week an Int
    case hoursInWorkWeek = "hoursInWorkWeekPrefKey"
    /// The Day of the week to reset the
    case resetDay        = "resetDayPrefKey"
    case resetHour       = "resetHourPrefKey"
    case workRadius      = "workRadiusPrefKey"
    case clearDate       = "clearDate"
    case onboardingComplete = "onboardingComplete"
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
    public func doubleForKey(defaultName: SettingsKey) ->Double {
        return doubleForKey(defaultName.rawValue)
    }
    public func setDouble(value: Double, forKey defaultName: SettingsKey){
        setDouble(value, forKey: defaultName.rawValue)
    }
    public func integerForKey(defaultName: SettingsKey) -> Int {
        return integerForKey(defaultName.rawValue)
    }
    public func setInteger(value: Int, forKey defaultName: SettingsKey){
        setInteger(value, forKey: defaultName.rawValue)
    }
    public func setObject(object: AnyObject, forKey key: SettingsKey){
        setObject(object, forKey: key.rawValue)
    }
    public func objectForKey(defaultName: SettingsKey) -> AnyObject?{
        return objectForKey(defaultName.rawValue)
    }
    public func boolForKey(defaultName: SettingsKey) -> Bool {
        return boolForKey(defaultName.rawValue)
    }
}


public func updateDefaultResetDate( defaults: NSUserDefaults = Defaults.standard){
    //get date from the settings
    if let date = getDateForReset(
        defaults.integerForKey(.resetDay),
        defaults.integerForKey(.resetHour),
        0) {
            defaults.setObject(date, forKey: .clearDate)
    } else {
        NSLog("Could not get a reset day for %@, %@",
            defaults.integerForKey(.resetDay),
            defaults.integerForKey(.resetHour))
    }
}