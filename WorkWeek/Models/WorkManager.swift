import Foundation


/// A struct with one static member to compute the Path to use when archiving data
///
/// Just call Archive.path to get a String? to use for archiving
private struct Archive {
    static var path: String? {
        let documentsDirectories = NSSearchPathForDirectoriesInDomains(
                                    .DocumentDirectory, .UserDomainMask, true)
        let documentDirectory = documentsDirectories.first
        if let dir = documentDirectory {
            return dir + "/items.archive"
        }
        return nil
    }
}

public class WorkManager : NSObject {

    public private(set) var eventsForTheWeek = NSMutableArray() {
        willSet {
            print("Events for the week Will Set did fire:")
            print("New Value: \(newValue)")
        }
    }

    func addOrRemoveNotification(newEvent: Event) {
        if newEvent.inOrOut == .Arrival {
            //do arrival stuff here
        } else if newEvent.inOrOut == .Departure {
            //do departure stuff here
        }
    }

    let localNotificationHandler = LocalNotifier()

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
    public override init() {
        super.init()
        // if we have archived events restore them
        eventsForTheWeek = restoreArchivedEvents() ?? NSMutableArray()
//        observeNotifications()
    }

    deinit{
//        stopObservingNotifications()
    }

    public func addArrival(date: NSDate = NSDate()) {
        //set up a notification to fire at 40 hours
        localNotificationHandler.setupNotification(hoursWorkedThisWeek, hoursInFullWorkWeek: hoursInWorkWeek)
        let newArrival = Event(inOrOut: .Arrival, date: date)
        print("Adding a New Arrival, \(newArrival.inOrOut.rawValue), with date \(newArrival.date)")
        eventsForTheWeek.addObject(newArrival)
        postNotification()
        saveNewArchive(eventsForTheWeek)
    }

    public func addDeparture(_ date: NSDate = NSDate()) {
        localNotificationHandler.cancelAllNotifications()
        let newDeparture = Event(inOrOut: .Departure, date: date)
        print("Adding a New Departure, \(newDeparture.inOrOut.rawValue), with date \(newDeparture.date)")
        eventsForTheWeek.addObject(newDeparture)
        postNotification()
        saveNewArchive(eventsForTheWeek)
        workDays = processEvents(eventsForTheWeek)

    }

    public func clearEvents() {
        eventsForTheWeek = NSMutableArray()
        postNotification()
        //clear the archive as well
        saveNewArchive(eventsForTheWeek)
    }

    public func addArrivalIfAtWork(locationManager: LocationManager) {
        //if you are currently at work add an arrival right now.
        if locationManager.atWork(){
            addArrival()
        }
    }

    func postNotification(center: NSNotificationCenter = NSNotificationCenter.defaultCenter()) {
        let note = NSNotification(name: "WorkWeekUpdated", object: nil)
        print("Posting Notification: \(note)")
        center.postNotification(note)
    }

    private func restoreArchivedEvents() -> NSMutableArray? {
        // Get the archived events, nil if there are none
        return NSKeyedUnarchiver.unarchiveMutableArrayWithFile(Archive.path)
    }

    private func saveNewArchive(events : NSMutableArray) -> Bool {
        if let path = Archive.path {
            return NSKeyedArchiver.archiveRootObject(self.eventsForTheWeek, toFile: path)
        }
        return false
    }


    public func allItems() -> [WorkDay] {
        workDays = processEvents(eventsForTheWeek)
        return workDays
    }

    public func processEvents(inEvents:  NSMutableArray ) -> [WorkDay] {
        // make a copy so we can mutate this
        let events = inEvents.mutableCopy() as! NSMutableArray
        var workTimes = [WorkDay]()
        //items should be paired, make sure first item is an arrival
        //if not drop it
        removeFirstObjectIfDeparture(events)

        while events.count >= 2 { //loop through events pairing them

            let first  = events.objectAtIndex(0) as! Event
            let second = events.objectAtIndex(1) as! Event
            if first.inOrOut == .Arrival &&
              second.inOrOut == .Departure {
                //we have two paired items
                let day = makeWorkDayFrom(event1: first, event2: second)
                workTimes.append(day)
            }
            events.removeObjectAtIndex(0) //remove the arrival
            events.removeObjectAtIndex(0) //remove the departure
        }

        return workTimes

    }

    private func removeFirstObjectIfDeparture(events: NSMutableArray){
        if events.count > 0  {
            if let first = events[0] as? Event {
                if first.inOrOut == .Departure {
                    events.removeObjectAtIndex(0)
                }
            }
        }
    }

    private func makeWorkDayFrom(event1 first: Event, event2 second: Event) -> WorkDay{
        let hoursMinutes = hoursMinutesFromDate(date: first.date, toDate: second.date)
        let workDay = WorkDay(weekDay: first.date.dayOfWeek,
                            hoursWorked: hoursMinutes.hours,
                            minutesWorked: hoursMinutes.minutes,
                            arrivalTime: first.timeString,
                            departureTime: second.timeString)
        return workDay
    }


    func resetDataIfNeeded(defaults: NSUserDefaults = Defaults.standard) {
        if let resetDate = defaults.objectForKey(.clearDate) as? NSDate {
            let now = NSDate()
            let comparison = resetDate.compare(now)
            switch comparison {
            case NSComparisonResult.OrderedSame:
                print("Same! nice work. lets clear it anyway")
                clearEvents()
                updateDefaultResetDate()
            case NSComparisonResult.OrderedAscending:
                print("Week has lapsed, Clearing Data")
                clearEvents()
                updateDefaultResetDate()
            case NSComparisonResult.OrderedDescending:
                //time has not yet elapsed do nothing
                print("Week has not yet finished, DO NOT Clear the data")
            }
        }
    }

    public func hoursSoFarToday() -> Double {
        if let lastArrival = eventsForTheWeek.lastObject as? Event {
            if lastArrival.inOrOut == .Arrival {
                let (h,m) = hoursMinutesFromDate(date: lastArrival.date, toDate: NSDate())
                let hoursToday = getDoubleFrom(hours: h, min: m)
                return hoursToday
            }
        }
        return 0
    }

}
