import Foundation

extension NSDate{

    var dayOfWeek: String {
        let weekdayFmt = NSDateFormatter()

        // "E" is for short weekday Tue for Tuesday, use EEEE for full weekday
        weekdayFmt.dateFormat = NSDateFormatter.dateFormatFromTemplate("E",
            options: 0, locale: NSLocale.currentLocale())
        return weekdayFmt.stringFromDate(self)
    }

}