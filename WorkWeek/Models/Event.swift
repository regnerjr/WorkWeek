import Foundation

///
/// Event class is used for storing arrivals and departures
/// Each event is either an arrival or a departure
/// and each event has a specific absolute date on which it happened
///
public struct Event {
    enum AD { //swiftlint:disable:this type_name
        case arrival
        case departure
    }
    let ad: AD //swiftlint:disable:this variable_name
    let date: Date

    /// timeString is a property which returns the short time for the event
    /// i.e. 8:34 AM
    var timeString: String {
        return Formatter.shortTime.string(from: self.date)
    }

    var timeSinceEventHoursDouble: Double {
        let (h, m) = hoursMinutesFromDate(date: self.date, toDate: Date())
        return getDoubleFrom(hours: h, min: m)
    }

    var dayOfWeek: String {
        return date.dayOfWeek
    }

    var timeSoFar: String {
        return Formatter.double
            .stringFromDouble(timeSinceEventHoursDouble)
    }

}

extension Event: Equatable {}
public func == (lhs: Event, rhs: Event) -> Bool {
    if lhs.ad == rhs.ad && lhs.date == rhs.date {
        return true
    } else {
        return false
    }
}

open class EncodeEvent: NSObject, NSCoding {

    let value: Event

    func arrivalDepartureObject(_ event: Event) -> AnyObject {
        switch event.ad {
        case .arrival: return NSNumber(value: true as Bool) // yes arbitrary mapping
        case .departure: return NSNumber(value: false as Bool)
        }
    }

    init(event: Event) {
        value = event
    }

    // NSCoding Conformance
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(arrivalDepartureObject(value), forKey: RestorationKey.inOrOut)
        aCoder.encode(value.date, forKey: RestorationKey.date)
    }

    required public init?(coder aDecoder: NSCoder) {
        guard let arrivalDeparture = aDecoder.decodeObject(
                                        forKey: RestorationKey.inOrOut) as? NSNumber else {
            fatalError("Error restoring From Archive \(aDecoder)")
        }
        guard let date = aDecoder.decodeObject(forKey: RestorationKey.date) as? Date else {
            fatalError("Error restoring Date from Archive \(aDecoder)")
        }
        switch arrivalDeparture.boolValue {
        case true: value = Event(ad: .arrival, date: date)
        case false: value = Event(ad: .departure, date: date)
        }
    }
}

public func getDoubleFrom(hours: Int, min: Int) -> Double {
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
