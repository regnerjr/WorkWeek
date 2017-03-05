import Foundation

public extension Date {
    /// A simple computed Property of NSDate which returns the short weekday for a given NSDate
    var dayOfWeek: String {
        let weekdayFmt = DateFormatter()

        // "E" is for short weekday Tue for Tuesday, use EEEE for full weekday
        weekdayFmt.dateFormat = "E"
        return weekdayFmt.string(from: self)
    }

}

/// Calculates the next NSDate which matches the given components
///
/// - parameter day: An Int indicating which day of the week is requested.
/// - parameter hour: An Int indicating which hour of the day
/// - parameter minute: An Int indicating which minute of the hour
/// - returns: The Next Date
///
public func getDateForReset(_ day: Int, hour: Int, minute: Int,
                            cal: Calendar = Calendar.current) -> Date {
    // Get the Calendar in use
    let todaysComps = (cal as NSCalendar).components([.weekday, .hour, .minute], from: Date())
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
    let date = (cal as NSCalendar).date(byAdding: resetComps, to: Date(),
        options: .matchNextTime)

    return date ?? Date()
}

/// Calculates the amount of time between two given dates
///
/// - parameter date: The first Date
/// - parameter toDate: The second Date
/// - returns: A tuple (hours, minutes) containing the elapsed time
///
public func hoursMinutesFromDate(date date1: Date,
                                 toDate date2: Date ) -> (hours: Int, minutes: Int) {
    let cal = Calendar.current
    let hour = (cal as NSCalendar).components(.hour, from: date1, to: date2, options: .matchStrictly).hour
    //gets the minutes not already included in an hour
    let min = (cal as NSCalendar).components(.minute, from: date1, to: date2,
                             options: .matchStrictly).minute! % 60
    return (hour!, min)
}
