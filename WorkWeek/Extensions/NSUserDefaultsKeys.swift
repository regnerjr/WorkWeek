import Foundation

/**
    The constant strings used for getting values in and out of NSUserDefaults
*/
public enum SettingsKey : String{

    /// Hours in a Work week an Int
    case hoursInWorkWeek = "hoursInWorkWeekPrefKey"
    /// The Day of the week to reset the
    case resetDay        = "resetDayPrefKey"
    case resetHour       = "resetHourPrefKey"
    case workRadius      = "workRadiusPrefKey"

}

/**
    A simpler way to access the NSUserDefaults.StandardUserDefaults()
    Purely a convenience.
*/
struct Defaults {
    static let standard = NSUserDefaults.standardUserDefaults()
}

//Wish I could break up the settings keys into classes whitch would constrain this so only the
//strings which control the double settings could be passes to doubleForKey
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
}