import Foundation


/// WorkDay is the combination of an Arrival Event and a Departure Event
/// Even if you arrive and depart work multiple times per day, 
/// each of these is considered a work day. 
/// This oject is used to share date between the work manager and the tableView
///
public struct WorkDay {
    let weekDay: String //string to store the weekday of the Arrival
    let hoursWorked: Int //counts Hours worked from arrival to departure
    let minutesWorked: Int //counts minutes not included in the Hours
    let arrivalTime: String
    let departureTime: String
    /// Note: This is returned as a string, because its main purpose in life is for display
    public var decimalHoursWorked : String {
        return Formatter.double.stringFromDouble( getDoubleFrom(hours: hoursWorked, min: minutesWorked) )
    }

    public init(weekDay:String, hoursWorked: Int, minutesWorked: Int,
        arrivalTime: String, departureTime: String) {
            self.weekDay = weekDay
            self.hoursWorked = hoursWorked
            self.minutesWorked = minutesWorked
            self.arrivalTime = arrivalTime
            self.departureTime = departureTime
    }
}