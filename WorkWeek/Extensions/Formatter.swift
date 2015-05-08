import Foundation
/** 
    Formatter is a wrapper around NSNumberFormatter and NSDateFormatter. 
    Available formatters are double, workHours, workRadius, and shortTime.

    Having these formatters defined here allows use without the tedious setup
    as well as allowing consistent formatting of numbers and dates throughout the app
*/
public struct Formatter {

    /// For numbers between 0.1 and 9.9
    /// only one decimal and one fractional digit is shown
    public static var double: NSNumberFormatter = {
        let doubleFormatter = NSNumberFormatter()
        doubleFormatter.numberStyle = .DecimalStyle
        doubleFormatter.minimum = 0.1
        doubleFormatter.maximum = 99.9
        doubleFormatter.minimumIntegerDigits = 1
        doubleFormatter.maximumIntegerDigits = 2
        doubleFormatter.minimumFractionDigits = 1
        doubleFormatter.maximumFractionDigits = 1
        doubleFormatter.roundingIncrement = 0.1
        doubleFormatter.roundingMode = .RoundHalfUp
        return doubleFormatter
    }()

    /// 1 to 2 digit integers
    public static var workHours: NSNumberFormatter = {
        let intFormatter = NSNumberFormatter()
        intFormatter.numberStyle = .NoStyle
        intFormatter.minimum = 1
        intFormatter.maximum = 99
        intFormatter.minimumIntegerDigits = 1
        intFormatter.maximumIntegerDigits = 2
        intFormatter.minimumFractionDigits = 0
        intFormatter.maximumFractionDigits = 0
        intFormatter.roundingIncrement = 1
        intFormatter.roundingMode = .RoundHalfUp
        return intFormatter
    }()

    /// For showing a work radius 50 to 999 integers only
    public static var workRadius: NSNumberFormatter = {
        let radiusFormatter = NSNumberFormatter()
        radiusFormatter.numberStyle = .NoStyle
        radiusFormatter.minimum = 50 //allow workRadius to be between 50 and 999 meters
        radiusFormatter.maximum = 999
        radiusFormatter.minimumIntegerDigits = 2
        radiusFormatter.maximumIntegerDigits = 3
        radiusFormatter.minimumFractionDigits = 0
        radiusFormatter.maximumFractionDigits = 0
        radiusFormatter.roundingIncrement = 1
        radiusFormatter.roundingMode = .RoundUp
        return radiusFormatter
    }()

    /// Date formatter set to short Time style
    /// and no dateStyle.NoStyle
    public static var shortTime: NSDateFormatter  = {
        let timeFormatter = NSDateFormatter()
        timeFormatter.timeStyle = .ShortStyle
        timeFormatter.dateStyle = .NoStyle
        return timeFormatter
    }()
    
}