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
    public static var double: NumberFormatter = {
        let doubleFormatter = NumberFormatter()
        doubleFormatter.numberStyle = .decimal
        doubleFormatter.minimum = 0.1
        doubleFormatter.maximum = 99.9
        doubleFormatter.minimumIntegerDigits = 1
        doubleFormatter.maximumIntegerDigits = 2
        doubleFormatter.minimumFractionDigits = 1
        doubleFormatter.maximumFractionDigits = 1
        doubleFormatter.roundingIncrement = 0.1
        doubleFormatter.roundingMode = .halfUp
        return doubleFormatter
    }()

    /// 1 to 2 digit integers
    public static var workHours: NumberFormatter = {
        let intFormatter = NumberFormatter()
        intFormatter.numberStyle = .none
        intFormatter.minimum = 1
        intFormatter.maximum = 99
        intFormatter.minimumIntegerDigits = 1
        intFormatter.maximumIntegerDigits = 2
        intFormatter.minimumFractionDigits = 0
        intFormatter.maximumFractionDigits = 0
        intFormatter.roundingIncrement = 1
        intFormatter.roundingMode = .halfUp
        return intFormatter
    }()

    /// For showing a work radius 50 to 999 integers only
    public static var workRadius: NumberFormatter = {
        let radiusFormatter = NumberFormatter()
        radiusFormatter.numberStyle = .none
        radiusFormatter.minimum = 0
        radiusFormatter.maximum = 999
        radiusFormatter.minimumIntegerDigits = 2
        radiusFormatter.maximumIntegerDigits = 3
        radiusFormatter.minimumFractionDigits = 0
        radiusFormatter.maximumFractionDigits = 0
        radiusFormatter.roundingIncrement = 1
        radiusFormatter.roundingMode = .up
        return radiusFormatter
    }()

    /// Date formatter set to short Time style
    /// and no dateStyle.NoStyle
    public static var shortTime: DateFormatter  = {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        timeFormatter.dateStyle = .none
        return timeFormatter
    }()

}
