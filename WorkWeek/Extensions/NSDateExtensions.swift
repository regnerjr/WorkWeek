import Foundation

public extension NSDate{
    /// A simple computed Property of NSDate which returns the short weekday for a given NSDate
    var dayOfWeek: String {
        let weekdayFmt = NSDateFormatter()

        // "E" is for short weekday Tue for Tuesday, use EEEE for full weekday
        weekdayFmt.dateFormat = NSDateFormatter.dateFormatFromTemplate("E",
            options: 0, locale: .currentLocale())
        return weekdayFmt.stringFromDate(self)
    }

}

/// Calculates the next NSDate which matches the given components
///
/// :param: day An Int indicating which day of the week is requested. 
/// :param:
/// :param:
/// :returns:
///
public func getDateForReset(day: Int, hour: Int, minute: Int) -> NSDate? {
    // Get the Calendar in use
    let cal = NSCalendar.currentCalendar()
    // Get the current day, Hour, Minute
    let todaysComps = cal.components(.CalendarUnitWeekday |
        .CalendarUnitHour |
        .CalendarUnitMinute
        , fromDate: NSDate())

    // Get the relative components,
    // This is where the real magic happens, How much time between now  and our reset time
    // in days hours minutes
    let resetComps = NSDateComponents()
    if (day + 1) < todaysComps.weekday {  //adjust for week wrap.
        resetComps.weekday = (day + 1) - todaysComps.weekday + 7
    } else {
        resetComps.weekday = (day + 1) - todaysComps.weekday
    }
    resetComps.hour   = hour - todaysComps.hour
    resetComps.minute = minute - todaysComps.minute

    // Taking the above differences, add them to now
    let date = cal.dateByAddingComponents(resetComps, toDate: NSDate(),
        options: .MatchNextTime)

    return date
}

/// Calculates the amount of time between two given dates
///
/// :param: date The first Date
/// :param: toDate The second Date
/// :returns: A tuple (hours, minutes) containing the elapsed time
///
public func hoursMinutesFromDate(date date1: NSDate, toDate date2: NSDate ) -> (hours: Int, minutes: Int){
    let cal = NSCalendar.currentCalendar()
    let hour = cal.components(.CalendarUnitHour, fromDate: date1, toDate: date2, options: .MatchStrictly).hour
    //gets the minutes not already included in an hour
    let min = cal.components(.CalendarUnitMinute, fromDate: date1, toDate: date2, options: .MatchStrictly).minute % 60
    return (hour, min)
}
