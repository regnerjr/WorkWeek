import Foundation

public class WorkManager {

    public var eventsForTheWeek: [Event] = []
    public var workDays: [WorkDay] = []
    public var hoursWorkedThisWeek: Double {
        let hoursWorked = workDays.reduce(0, combine: {$0 + $1.hoursWorked})
        let hourFractions = workDays.reduce(0, combine: {$0 + $1.minutesWorked})
        return Double(hoursWorked) + Double(hourFractions) / 60.0
    }

    public init(){}
    
    public func addArrival(date: NSDate){
        let newArrival = Event(inOrOut: .Arrival, date: date)
        eventsForTheWeek.append(newArrival)
    }

    public func addDeparture(date: NSDate){
        let newDeparture = Event(inOrOut: .Departure, date: date)
        eventsForTheWeek.append(newDeparture)
        workDays = processEvents(eventsForTheWeek)
    }

    public func isAtWork() -> Bool {
        if let lastEvent = eventsForTheWeek.last{
            return lastEvent.inOrOut == .Arrival //if the last event was an arrival return true
        }
        return false // if no events then there has not been an arrival
    }

    public func clearEvents(){
        eventsForTheWeek = [Event]()
    }

    public func allItems() -> [WorkDay]{
        workDays = processEvents(eventsForTheWeek)
        return workDays
    }

    //What we need is a loop to process the events and turn them into workdays
    public func processEvents(var events: [Event]) -> [WorkDay]{
        var workTimes = [WorkDay]()
        //items should be paired, make sure first item is an arrival
        //if not drop it
        if events.count > 0 && events[0].inOrOut != .Arrival {
            events.removeAtIndex(0)
        }

        while events.count >= 2 { //loop through events pairing them

            //still need to check length of the array
            if events.count >= 2 {
                if events[0].inOrOut == .Arrival && events[1].inOrOut == .Departure {
                //we have two paired items
                let hoursMinutes = hoursMinutesFromDate(date: events[0].date, toDate: events[1].date)
                let workDay = WorkDay(weekDay: events[0].date.dayOfWeek, hoursWorked:hoursMinutes.hours, minutesWorked: hoursMinutes.minutes, arrivalTime: events[0].timeString, departureTime: events[1].timeString)
                workTimes.append(workDay)
                events.removeAtIndex(0) //remove the arrival
                events.removeAtIndex(0) //remove the departure
                }
            }
            
        }
        
        return workTimes
    }
}

public func hoursMinutesFromDate(date date1: NSDate, toDate date2: NSDate ) -> (hours: Int, minutes: Int){
    let cal = NSCalendar.currentCalendar()
    let hour = cal.components(NSCalendarUnit.HourCalendarUnit, fromDate: date1, toDate: date2, options: NSCalendarOptions.MatchStrictly).hour
    //gets the minutes not already included in an hour
    let min = cal.components(NSCalendarUnit.MinuteCalendarUnit, fromDate: date1, toDate: date2, options: NSCalendarOptions.MatchStrictly).minute % 60
    return (hour, min)
}