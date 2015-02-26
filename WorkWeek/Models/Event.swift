import Foundation

enum AD: String {
    case Arrival = "Arrival"
    case Departure = "Departure"
}


struct Event {
    let inOrOut: AD
    let date: NSDate
    var timeString: String {
        let timeFormatter = NSDateFormatter()
        timeFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        timeFormatter.dateStyle = NSDateFormatterStyle.NoStyle
        return timeFormatter.stringFromDate(self.date)
    }
}