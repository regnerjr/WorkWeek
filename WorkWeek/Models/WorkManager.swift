import Foundation

private struct Archive {
    static var path: String? {
        let documentsDirectories = NSSearchPathForDirectoriesInDomains(
                                    .DocumentDirectory, .UserDomainMask, true) as? [String]
        let documentDirectory = documentsDirectories?.first
        if let dir = documentDirectory {
            return dir + "/items.archive"
        }
        return nil
    }
}

public class WorkManager : NSObject {

    public var eventsForTheWeek = NSMutableArray()
    private var workDays = Array<WorkDay>()
    public var hoursWorkedThisWeek: Double {
        let hoursWorked = workDays.reduce(0, combine: {$0 + $1.hoursWorked})
        let hourFractions = workDays.reduce(0, combine: {$0 + $1.minutesWorked})
        return Double(hoursWorked) + Double(hourFractions) / 60.0
    }
    var hoursInWorkWeek: Int {
        return Defaults.standard.integerForKey(.hoursInWorkWeek)
    }
    public var isAtWork: Bool {
        if let lastEvent = eventsForTheWeek.lastObject as? Event{
            return lastEvent.inOrOut == .Arrival //if the last event was an arrival return true
        }
        return false // if no events then there has not been an arrival
    }

    // MARK: - Init
    public override init(){
        super.init()
        // if we have archived events restore them
        if let eventArchive = restoreArchivedEvents() {
            self.eventsForTheWeek = eventArchive
        }
    }

    func restoreArchivedEvents() -> NSMutableArray? {
        // Get the archived events, nil if there are none
        if let path = Archive.path {
            return NSKeyedUnarchiver.unarchiveObjectWithFile(path) as! NSMutableArray?
        } else {
            return nil
        }
    }

    public func addArrival(date: NSDate){
        //set up a notification to fire at 40 hours
        LocalNotifier.setupNotification(hoursWorkedThisWeek, total: hoursInWorkWeek)
        let newArrival = Event(inOrOut: .Arrival, date: date)
        eventsForTheWeek.addObject(newArrival)
        saveNewArchive(eventsForTheWeek)
    }

    public func addDeparture(date: NSDate){
        LocalNotifier.cancelAllNotifications()
        let newDeparture = Event(inOrOut: .Departure, date: date)
        eventsForTheWeek.addObject(newDeparture)
        saveNewArchive(eventsForTheWeek)
        workDays = processEvents(eventsForTheWeek)
    }

    func saveNewArchive(events : NSMutableArray) -> Bool{
        if let path = Archive.path {
            return NSKeyedArchiver.archiveRootObject(self.eventsForTheWeek, toFile: path)
        }
        return false
    }

    public func clearEvents(){
        eventsForTheWeek = NSMutableArray()
        //clear the archive as well
        saveNewArchive(eventsForTheWeek)
    }

    public func allItems() -> [WorkDay]{
        workDays = processEvents(eventsForTheWeek)
        return workDays
    }

    public func processEvents(inEvents:  NSMutableArray ) -> [WorkDay]{
        // make a copy so we can mutate this
        let events = inEvents.mutableCopy() as! NSMutableArray
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
                let first  = events.objectAtIndex(0) as! Event
                let second = events.objectAtIndex(1) as! Event
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
                }
                events.removeObjectAtIndex(0) //remove the arrival
                events.removeObjectAtIndex(0) //remove the departure
            }

        }

        return workTimes
    }

    func resetDataIfNeeded(defaults: NSUserDefaults = Defaults.standard) {
        if let resetDate = defaults.objectForKey(SettingsKey.clearDate.rawValue) as! NSDate? {
            let now = NSDate()
            let comparison = resetDate.compare(now)
            NSLog("WorkManager: Comparing Reset Date to now - %d", comparison.rawValue)
            switch comparison {
            case NSComparisonResult.OrderedSame:
                println("Same! nice work. lets clear it anyway")
                clearEvents()
                updateDefaultResetDate()
            case NSComparisonResult.OrderedAscending:
                println("Week has lapsed, Clearing Data")
                clearEvents()
                updateDefaultResetDate()
            case NSComparisonResult.OrderedDescending:
                //time has not yet elapsed do nothing
                println("Week has not yet finished, DO NOT Clear the data")
            }
        }
    }
}

public func hoursMinutesFromDate(date date1: NSDate, toDate date2: NSDate ) -> (hours: Int, minutes: Int){
    let cal = NSCalendar.currentCalendar()
    let hour = cal.components(.CalendarUnitHour, fromDate: date1, toDate: date2, options: .MatchStrictly).hour
    //gets the minutes not already included in an hour
    let min = cal.components(.CalendarUnitMinute, fromDate: date1, toDate: date2, options: .MatchStrictly).minute % 60
    return (hour, min)
}
