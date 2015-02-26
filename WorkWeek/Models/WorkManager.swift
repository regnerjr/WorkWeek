import Foundation


struct CompleteDay {
    let dayOfWeekString: String
    //    let HoursWorked:
}

class WorkManager {
    var eventsForTheWeek: [Event] = []
    func addArrival(date: NSDate){
        let newArrival = Event(inOrOut: .Arrival, date: date)
        eventsForTheWeek.append(newArrival)
    }

    func addDeparture(date: NSDate){
        let newDeparture = Event(inOrOut: .Departure, date: date)
        eventsForTheWeek.append(newDeparture)

        //check event before the one we just added
        let arrivalDate = eventsForTheWeek[eventsForTheWeek.count - 2].date
        let timeWorked = hoursMinutesFromDate(date: arrivalDate, toDate: newDeparture.date)
    }

    func isAtWork() -> Bool {
        if let lastEvent = eventsForTheWeek.last{
            return lastEvent.inOrOut == .Arrival //if the last event was an arrival return true
        }
        return false // if no events then there has not been an arrival
    }
    func clearEvents(){
        eventsForTheWeek = [Event]()
    }
    func timeWorkedOnDay(date: NSDate) -> (hours:Int, minutes: Int){
        let eventsForWeekday = eventsForTheWeek.reduce([Event](), combine: { //get only items for work matching weekday requested
            if $1.date.dayOfWeek == date.dayOfWeek{
                $0 + [$1]
            }
            return $0
        })
        if eventsForWeekday.first?.inOrOut != .Arrival {
            println("First item is not an arrival!")
            return (0, 0)
        }
        return hoursMinutesFromDate(date: eventsForWeekday[0].date, toDate: eventsForWeekday[1].date)
    }
    func allItems() -> [String]{
        return ["Item1", "Item2", "Item3"]
    }
}

func hoursMinutesFromDate(date date1: NSDate, toDate date2: NSDate ) -> (hours: Int, minutes: Int){
    let cal = NSCalendar.currentCalendar()
    let hour = cal.components(NSCalendarUnit.HourCalendarUnit, fromDate: date1, toDate: date2, options: NSCalendarOptions.MatchStrictly).hour
    //gets the minutes not already included in an hour
    let min = cal.components(NSCalendarUnit.MinuteCalendarUnit, fromDate: date1, toDate: date2, options: NSCalendarOptions.MatchStrictly).minute % 60
    return (hour, min)
}

