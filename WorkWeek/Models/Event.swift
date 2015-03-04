import Foundation

public enum AD: String {
     case Arrival = "Arrival"
     case Departure = "Departure"
}


public struct Event {
    public let inOrOut: AD
    public let date: NSDate

    public init(inOrOut: AD, date: NSDate){
        self.inOrOut = inOrOut
        self.date = date
    }
    
    var timeString: String {
        let timeFormatter = NSDateFormatter()
        timeFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        timeFormatter.dateStyle = NSDateFormatterStyle.NoStyle
        return timeFormatter.stringFromDate(self.date)
    }

}

// MARK: - Equatable
extension Event: Equatable {}
public func ==(lhs: Event, rhs: Event) -> Bool {
    return (lhs.inOrOut == rhs.inOrOut) && (lhs.date == rhs.date)
}

// MARK: - WorkHours

public struct WorkDay {
    let weekDay: String //string to store the weekday of the Arrival
    let hoursWorked: Int //counts Hours worked from arrival to departure
    let minutesWorked: Int //counts minutes not included in the Hours
    let arrivalTime: String
    let departureTime: String
    init(weekDay:String, hoursWorked: Int, minutesWorked: Int, arrivalTime: String, departureTime: String){
        self.weekDay = weekDay
        self.hoursWorked = hoursWorked
        self.minutesWorked = minutesWorked
        self.arrivalTime = arrivalTime
        self.departureTime = departureTime
    }
}