import Foundation

/// Enum for tracking Arrivals and Departures
/// These items are Mutually exclusive thus this amazing enum
public enum AD: String {
     case Arrival = "Arrival"
     case Departure = "Departure"
}

///
/// Event class is used for storing arrivals and departures
/// Each event is either an arrival or a departure
/// and each event has a specific absolute date on which it happened
///
public class Event: NSObject, NSCoding{
    
    public let inOrOut: AD
    public let date: NSDate

    /// timeString is a property which returns the short time for the event
    /// i.e. 8:34 AM
    var timeString: String {
        return Formatter.shortTime.stringFromDate(date)
    }

    /// Create an event by passing AD.Arrival or AD.Departure, and an NSDate
    public init(inOrOut: AD, date: NSDate){
        self.inOrOut = inOrOut
        self.date = date
    }

    // MARK: - NSCoding
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.inOrOut.rawValue, forKey: "inOrOut")
        aCoder.encodeObject(self.date, forKey: "date")
    }

    required public init(coder aDecoder: NSCoder) {
        let inOutString = aDecoder.decodeObjectForKey("inOrOut") as! String? ?? ""
        switch inOutString {
        case "Arrival": self.inOrOut = .Arrival
        case "Departure": self.inOrOut = .Departure
        default: fatalError("UnArchiving inOrOut failed with string unknown string \(inOutString)")
        }
        self.date = aDecoder.decodeObjectForKey("date") as! NSDate? ?? NSDate()
    }
}

// MARK: - Equatable
extension Event: Equatable {}
public func ==(lhs: Event, rhs: Event) -> Bool {
    return (lhs.inOrOut == rhs.inOrOut) && (lhs.date == rhs.date)
}

public func getDoubleFrom(#hours: Int, #min: Int) -> Double {
    let dbl = Double(min)
    let roundedMin = (dbl / 60.0)
    let flr = floor(roundedMin * 10 ) / 10
    return Double(hours) + floor(roundedMin * 10) / 10
}