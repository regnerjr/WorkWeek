import Foundation

public extension Date {
    /// A simple computed Property of Date which returns the short weekday for a given Date
    var dayOfWeek: String {
        let weekdayFmt = DateFormatter()

        // "E" is for short weekday Tue for Tuesday, use EEEE for full weekday
        weekdayFmt.dateFormat = "E"
        return weekdayFmt.string(from: self)
    }

}

/// Calculates the next Date which matches the given components
///
/// - parameter day: An Int indicating which day of the week is requested.
/// - parameter hour: An Int indicating which hour of the day
/// - parameter minute: An Int indicating which minute of the hour
/// - returns: The Next Date
///
public func getDateForReset(_ day: Int, hour: Int, minute: Int,
                            cal: Calendar = Calendar.current) -> Date {
    // Get the Calendar in use
    let todaysComps = cal.dateComponents([.weekday, .hour, .minute], from: Date())
    // Get the relative components,
    // This is where the real magic happens, How much time between now  and our reset time
    // in days hours minutes
    var resetComps = DateComponents()

    if (day + 1) <= todaysComps.weekday! {  //adjust for week wrap.
        resetComps.weekday = (day + 1) - todaysComps.weekday! + 7
    } else {
        resetComps.weekday = (day + 1) - todaysComps.weekday!
    }
    resetComps.hour   = hour - todaysComps.hour!
    resetComps.minute = minute - todaysComps.minute!

    // Taking the above differences, add them to now
    let date = cal.date(byAdding: resetComps, to: Date())

    return date! //swiftlint:disable:this force_cast
}

/// Calculates the amount of time between two given dates
///
/// - parameter date: The first Date
/// - parameter toDate: The second Date
/// - returns: A tuple (hours, minutes) containing the elapsed time
///
public func hoursMinutesFromDate(date startDate: Date,
                                 toDate endDate: Date ) -> (hours: Int, minutes: Int) {
    let cal = Calendar.current
    let comps = cal.dateComponents([.hour, .minute], from: startDate, to: endDate)
    return (comps.hour!, comps.minute!)
}
