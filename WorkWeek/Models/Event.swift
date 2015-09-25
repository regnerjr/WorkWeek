import Foundation

///
/// Event class is used for storing arrivals and departures
/// Each event is either an arrival or a departure
/// and each event has a specific absolute date on which it happened
///
public struct Event {
    enum AD {
        case Arrival
        case Departure
    }
    let ad: AD
    let date: NSDate

    /// timeString is a property which returns the short time for the event
    /// i.e. 8:34 AM
    var timeString: String {
        return Formatter.shortTime.stringFromDate(self.date)
    }

    var timeSinceEventHoursDouble: Double {
        let (h,m) = hoursMinutesFromDate(date: self.date, toDate: NSDate())
        return getDoubleFrom(hours: h, min: m)
    }

}

extension Event: Equatable {}
public func ==(lhs: Event, rhs: Event) -> Bool {
    if lhs.ad == rhs.ad && lhs.date == rhs.date{
        return true
    } else {
        return false
    }
}

public class EncodeEvent: NSObject, NSCoding {

    let value: Event

    func arrivalDepartureObject(ev: Event) -> AnyObject{
        switch ev.ad {
        case .Arrival: return NSNumber(bool: true) // yes arbitrary mapping
        case .Departure: return NSNumber(bool: false)
        }
    }

    init(ev: Event){
        value = ev
    }

    // NSCoding Conformance
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(arrivalDepartureObject(value), forKey: RestorationKey.inOrOut)
        aCoder.encodeObject(value.date, forKey: RestorationKey.date)
    }

    required public init?(coder aDecoder: NSCoder) {
        guard let arrivalDeparture = aDecoder.decodeObjectForKey( RestorationKey.inOrOut) as? NSNumber else {
            fatalError("Error restoring From Archive \(aDecoder)")
        }
        guard let date = aDecoder.decodeObjectForKey(RestorationKey.date) as? NSDate else {
            fatalError("Error restoring Date from Archive \(aDecoder)")
        }
        switch arrivalDeparture.boolValue {
        case true: value = Event(ad: .Arrival, date: date)
        case false: value = Event(ad: .Departure, date: date)
        }
    }
}


public func getDoubleFrom(hours hours: Int, min: Int) -> Double {
    let dbl = Double(min)
    let roundedMin = (dbl / 60.0)
    let flr = floor(roundedMin * 10 ) / 10
    return Double(hours) + flr
}

/// Struct to hold the keys used for NSCoding
struct RestorationKey {
    static var inOrOut: String { return "inOrOut" }
    static var date: String { return "date" }
}
