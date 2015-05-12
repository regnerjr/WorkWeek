import Foundation

public extension NSDate{

    var dayOfWeek: String {
        let weekdayFmt = NSDateFormatter()

        // "E" is for short weekday Tue for Tuesday, use EEEE for full weekday
        weekdayFmt.dateFormat = NSDateFormatter.dateFormatFromTemplate("E",
            options: 0, locale: .currentLocale())
        return weekdayFmt.stringFromDate(self)
    }

}

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