import Foundation

private struct Archive {
    static var path: String? {
        let documentsDirectories = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,
                                        NSSearchPathDomainMask.UserDomainMask, true) as? [String]
        let documentDirectory = documentsDirectories?.first
        if let dir = documentDirectory {
            let documentPath = dir + "/items.archive"
            return documentPath
        }
        return nil
    }
}

public class WorkManager {

    public var eventsForTheWeek: NSMutableArray = NSMutableArray()

    public var workDays: [WorkDay] = Array<WorkDay>()

    public var hoursWorkedThisWeek: Double {
        let hoursWorked = workDays.reduce(0, combine: {$0 + $1.hoursWorked})
        let hourFractions = workDays.reduce(0, combine: {$0 + $1.minutesWorked})
        return Double(hoursWorked) + Double(hourFractions) / 60.0
    }

    init(){
        // if we have archived events restore them
        let eventArchive = restoreArchivedEvents()
        map(eventArchive, { events -> Void in
            self.eventsForTheWeek = events
        })
    }

    func restoreArchivedEvents() -> NSMutableArray? {
        // Get the archived events, nil if there are none
        // if let path = Archive.path {
        map(Archive.path) { path -> NSMutableArray? in
            let restored = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as NSMutableArray?
            return restored // if restore failed `restored` will be nil
        }
        return nil
    }

    func saveNewArchive(events : NSMutableArray) -> Bool{
        map(Archive.path) { path -> Bool in
            let result = NSKeyedArchiver.archiveRootObject(self.eventsForTheWeek, toFile: path)
            return result
        }
        return false
    }
    
    public func addArrival(date: NSDate){
        let newArrival = Event(inOrOut: .Arrival, date: date)
        eventsForTheWeek.addObject(newArrival)
        saveNewArchive(eventsForTheWeek)
    }

    public func addDeparture(date: NSDate){
        let newDeparture = Event(inOrOut: .Departure, date: date)
        eventsForTheWeek.addObject(newDeparture)
        saveNewArchive(eventsForTheWeek)
        workDays = processEvents(eventsForTheWeek)
    }

    public func isAtWork() -> Bool {
        if let lastEvent = eventsForTheWeek.lastObject as? Event{
            return lastEvent.inOrOut == .Arrival //if the last event was an arrival return true
        }
        return false // if no events then there has not been an arrival
    }

    public func clearEvents(){
        eventsForTheWeek = NSMutableArray()
    }

    public func allItems() -> [WorkDay]{
        workDays = processEvents(eventsForTheWeek)
        return workDays
    }

    //What we need is a loop to process the events and turn them into workdays
    public func processEvents(inEvents:  NSMutableArray ) -> [WorkDay]{
        // make a copy so we can mutate this
        let events = inEvents.mutableCopy() as NSMutableArray
        var workTimes = [WorkDay]()
        //items should be paired, make sure first item is an arrival
        //if not drop it
        if events.count > 0  {
            if let first = events[0] as? Event {
                if first.inOrOut == .Departure {
                    events.removeObjectAtIndex(0)
                }
            }
        }

        while events.count >= 2 { //loop through events pairing them

            //still need to check length of the array
            if events.count >= 2 {
                let first  = events.objectAtIndex(0) as Event
                let second = events.objectAtIndex(1) as Event
                if first.inOrOut == .Arrival &&
                  second.inOrOut == .Departure {
                    //we have two paired items
                    let hoursMinutes = hoursMinutesFromDate(date: first.date, toDate: second.date)
                    let workDay = WorkDay(weekDay: events[0].date.dayOfWeek,
                                        hoursWorked: hoursMinutes.hours,
                                        minutesWorked: hoursMinutes.minutes,
                                        arrivalTime: first.timeString,
                                        departureTime: second.timeString)
                    workTimes.append(workDay)
                    events.removeObjectAtIndex(0) //remove the arrival
                    events.removeObjectAtIndex(0) //remove the departure
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