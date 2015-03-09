import Foundation

struct Formatter {

    static var double: NSNumberFormatter = {
        let doubleFormatter = NSNumberFormatter()
        doubleFormatter.numberStyle = .DecimalStyle
        doubleFormatter.minimum = 0.1
        doubleFormatter.maximum = 9.9
        doubleFormatter.minimumIntegerDigits = 1
        doubleFormatter.maximumIntegerDigits = 1
        doubleFormatter.minimumFractionDigits = 1
        doubleFormatter.maximumFractionDigits = 1
        doubleFormatter.roundingIncrement = 0.1
        doubleFormatter.roundingMode = NSNumberFormatterRoundingMode.RoundUp
        return doubleFormatter
    }()

    static var workHours: NSNumberFormatter = {
        let intFormatter = NSNumberFormatter()
        intFormatter.numberStyle = NSNumberFormatterStyle.NoStyle
        intFormatter.minimum = 1
        intFormatter.maximum = 99
        intFormatter.minimumIntegerDigits = 1
        intFormatter.maximumIntegerDigits = 2
        intFormatter.minimumFractionDigits = 0
        intFormatter.maximumFractionDigits = 0
        intFormatter.roundingIncrement = 1
        intFormatter.roundingMode = NSNumberFormatterRoundingMode.RoundUp
        return intFormatter
    }()

    static var workRadius: NSNumberFormatter = {
        let radiusFormatter = NSNumberFormatter()
        radiusFormatter.numberStyle = NSNumberFormatterStyle.NoStyle
        radiusFormatter.minimum = 50 //allow workRadius to be between 50 and 999 meters
        radiusFormatter.maximum = 999
        radiusFormatter.minimumIntegerDigits = 2
        radiusFormatter.maximumIntegerDigits = 3
        radiusFormatter.minimumFractionDigits = 0
        radiusFormatter.maximumFractionDigits = 0
        radiusFormatter.roundingIncrement = 1
        radiusFormatter.roundingMode = NSNumberFormatterRoundingMode.RoundUp
        return radiusFormatter
    }()

    static var shortTime: NSDateFormatter  = {
        let timeFormatter = NSDateFormatter()
        timeFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        timeFormatter.dateStyle = NSDateFormatterStyle.NoStyle
        return timeFormatter
    }()
    
}