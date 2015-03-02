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

// MARK: - Equatable
extension Event: Equatable {}
func ==(lhs: Event, rhs: Event) -> Bool {
    return (lhs.inOrOut == rhs.inOrOut) && (lhs.date == rhs.date)
}

// MARK: - WorkHours

struct WorkDay {
    let weekDay: String //string to store the weekday of the Arrival
    let hoursWorked: Int //counts Hours worked from arrival to departure
    let minutesWorked: Int //counts minutes not included in the Hours
    let arrivalTime: String
    let departureTime: String
}