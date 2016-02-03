import Foundation

/// A struct with one static member to compute the Path to use when archiving data
///
/// Just call Archive.path to get a String? to use for archiving
struct Archive {
    static var path: String? {
        let documentsDirectories = NSSearchPathForDirectoriesInDomains(
                                    .DocumentDirectory, .UserDomainMask, true)
        return documentsDirectories.first.map{$0 + "/items.archive"}
    }
}

public class WorkManager : NSObject {

    public private(set) var eventsForTheWeek = Array<Event>() {
        willSet {
            print("Events for the week Will Set did fire:")
            print("New Value: \(newValue)")
        }
    }

    var localNotificationHandler = LocalNotifier()

    private var workDays = Array<WorkDay>()

    public var hoursWorkedThisWeek: Double {
        let hoursWorked = workDays.reduce(0, combine: {$0 + $1.hoursWorked})
        let hourFractions = workDays.reduce(0, combine: {$0 + $1.minutesWorked})
        return Double(hoursWorked) + Double(hourFractions) / 60.0
    }

    var hoursInWorkWeek: Int {
        return Defaults.standard.integerForKey(.HoursInWorkWeek)
    }

    public var isAtWork: Bool {
        guard let event = eventsForTheWeek.last else {
            return false //never been there not there now
        }
        switch event.ad {
        case .Arrival: return true
        case .Departure: return false
        }
    }

    // MARK: - Init
    public override init() {
        super.init()
        eventsForTheWeek = restoreArchivedEvents() ?? Array<Event>()
    }

    public func addArrival(date: NSDate = NSDate()) {
        //set up a notification to fire at 40 hours
        localNotificationHandler.setupNotification(hoursWorkedThisWeek, hoursInFullWorkWeek: hoursInWorkWeek)
        let newArrival = Event(ad: .Arrival, date: date)
        print("Adding a New Arrival, \(newArrival), with date \(newArrival.date)")
        eventsForTheWeek.append(newArrival)
        postNotification()
        saveNewArchive(eventsForTheWeek)
    }

    public func addDeparture(date: NSDate = NSDate()) {
        localNotificationHandler.cancelAllNotifications()
        let departure = Event(ad: .Departure, date: date)
        print("Adding a New Departure, \(departure), with date \(departure.date)")
        eventsForTheWeek.append(departure)
        postNotification()
        saveNewArchive(eventsForTheWeek)
        workDays = processEvents(eventsForTheWeek)

    }

    public func clearEvents() {
        eventsForTheWeek = Array<Event>()
        postNotification()
        //clear the archive as well
        saveNewArchive(eventsForTheWeek)
    }

    func addArrivalIfAtWork(locationManager: LocationManager) {
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

    private func restoreArchivedEvents() -> Array<Event>? {
        // Get the archived events, nil if there are none
        guard let objects =  NSKeyedUnarchiver.unarchiveMutableArrayWithFile(Archive.path) else {
            return nil
        }
        print(objects)
        var restored = Array<Event>()
        for item in objects {
            guard let item = item as? EncodeEvent else {
                fatalError("turns out you can't do this cast! ")
            }
            restored.append(item.value)
        }
        return restored
    }

    private func saveNewArchive(events: Array<Event>) -> Bool {
        let archiveArray = NSMutableArray()
        archiveArray.addObjectsFromArray(events.map{EncodeEvent(ev: $0)})
        if let path = Archive.path {
            return NSKeyedArchiver.archiveRootObject(archiveArray, toFile: path)
        }
        return false
    }

    public func allItems() -> [WorkDay] {
        workDays = processEvents(eventsForTheWeek)
        return workDays
    }

    public func processEvents(var inEvents:  Array<Event> ) -> [WorkDay] {
        // make a copy so we can mutate this
        var workTimes = [WorkDay]()
        //items should be paired, make sure first item is an arrival
        //if not drop it
        inEvents = removeFirstObjectIfDeparture(inEvents)

        while inEvents.count >= 2 { //loop through events pairing them
            let first  = inEvents.removeAtIndex(0)
            let second = inEvents.removeAtIndex(0)

            switch (first.ad, second.ad){
            case (.Arrival, .Departure):
                let day = makeWorkDayFrom(event1: first, event2: second)
                workTimes.append(day)
            case (_,_): continue
            }
        }

        return workTimes
    }

    private func removeFirstObjectIfDeparture(var events: Array<Event>) -> Array<Event>{
        if events.count > 0  {
            if events.first?.ad == .Departure {
                events.removeFirst()
                return events
            }
        }
        return events
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
        if let resetDate = defaults.objectForKey(.ClearDate) as? NSDate {
            switch resetDate.compare(NSDate()) {
            case .OrderedSame:
                clearEvents()
                updateDefaultResetDate()
            case .OrderedAscending:
                clearEvents()
                updateDefaultResetDate()
            case .OrderedDescending:
                //time has not yet elapsed do nothing
                print("Week has not yet finished, DO NOT Clear the data")
            }
        }
    }

    var lastArrival: Event? {
        guard let lastArrival = eventsForTheWeek.last where lastArrival.ad == .Arrival  else {
            return nil
        }
        return lastArrival
    }

    public func hoursSoFarToday() -> Double {
        if let lastArrival = lastArrival {
            let (h,m) = hoursMinutesFromDate(date: lastArrival.date, toDate: NSDate())
            let hoursToday = getDoubleFrom(hours: h, min: m)
            return hoursToday
        }
        return 0
    }

}
