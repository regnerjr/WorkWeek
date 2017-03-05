import Foundation

/// A struct with one static member to compute the Path to use when archiving data
///
/// Just call Archive.path to get a String? to use for archiving
struct Archive {
    static var path: String? {
        let documentsDirectories = NSSearchPathForDirectoriesInDomains(
                                    .documentDirectory, .userDomainMask, true)
        return documentsDirectories.first.map {$0 + "/items.archive"}
    }
}

open class WorkManager: NSObject {

    open fileprivate(set) var eventsForTheWeek = [Event]() {
        willSet {
            print("Events for the week Will Set did fire:")
            print("New Value: \(newValue)")
        }
    }

    var localNotificationHandler = LocalNotifier()

    fileprivate var workDays = [WorkDay]()

    open var hoursWorkedThisWeek: Double {
        let hoursWorked = workDays.reduce(0, {$0 + $1.hoursWorked})
        let hourFractions = workDays.reduce(0, {$0 + $1.minutesWorked})
        return Double(hoursWorked) + Double(hourFractions) / 60.0
    }

    var hoursInWorkWeek: Int {
        return Defaults.standard.integerForKey(.HoursInWorkWeek)
    }

    open var isAtWork: Bool {
        guard let event = eventsForTheWeek.last else {
            return false //never been there not there now
        }
        switch event.ad {
        case .arrival: return true
        case .departure: return false
        }
    }

    // MARK: - Init
    public override init() {
        super.init()
        eventsForTheWeek = restoreArchivedEvents() ?? [Event]()
    }

    open func addArrival(_ date: Date = Date()) {
        //set up a notification to fire at 40 hours
        localNotificationHandler.setupNotification(hoursWorkedThisWeek,
                                                   hoursInFullWorkWeek: hoursInWorkWeek)
        let newArrival = Event(ad: .arrival, date: date)
        print("Adding a New Arrival, \(newArrival), with date \(newArrival.date)")
        eventsForTheWeek.append(newArrival)
        postNotification()
        saveNewArchive(eventsForTheWeek)
    }

    open func addDeparture(_ date: Date = Date()) {
        localNotificationHandler.cancelAllNotifications()
        let departure = Event(ad: .departure, date: date)
        print("Adding a New Departure, \(departure), with date \(departure.date)")
        eventsForTheWeek.append(departure)
        postNotification()
        saveNewArchive(eventsForTheWeek)
        workDays = processEvents(eventsForTheWeek)

    }

    open func clearEvents() {
        eventsForTheWeek = [Event]()
        postNotification()
        //clear the archive as well
        saveNewArchive(eventsForTheWeek)
    }

    func addArrivalIfAtWork(_ locationManager: LocationManager) {
        //if you are currently at work add an arrival right now.
        if locationManager.atWork() {
            addArrival()
        }
    }

    func postNotification(_ center: NotificationCenter = NotificationCenter.default) {
        let note = Notification(name: Notification.Name(rawValue: "WorkWeekUpdated"), object: nil)
        print("Posting Notification: \(note)")
        center.post(note)
    }

    fileprivate func restoreArchivedEvents() -> [Event]? {
        // Get the archived events, nil if there are none
        guard let objects =  NSKeyedUnarchiver.unarchiveMutableArrayWithFile(Archive.path) else {
            return nil
        }
        print(objects)
        var restored = [Event]()
        for item in objects {
            guard let item = item as? EncodeEvent else {
                fatalError("turns out you can't do this cast! ")
            }
            restored.append(item.value)
        }
        return restored
    }

    @discardableResult
    fileprivate func saveNewArchive(_ events: [Event]) -> Bool {
        let archiveArray = NSMutableArray()
        archiveArray.addObjects(from: events.map {EncodeEvent(event: $0)})
        if let path = Archive.path {
            return NSKeyedArchiver.archiveRootObject(archiveArray, toFile: path)
        }
        return false
    }

    open func allItems() -> [WorkDay] {
        workDays = processEvents(eventsForTheWeek)
        return workDays
    }

    open func processEvents(_ inEvents: [Event] ) -> [WorkDay] {
        // make a copy so we can mutate this
        var workTimes = [WorkDay]()
        //items should be paired, make sure first item is an arrival
        //if not drop it
        var modifiedEvents = removeFirstObjectIfDeparture(inEvents)

        while modifiedEvents.count >= 2 { //loop through events pairing them
            let first  = modifiedEvents.remove(at: 0)
            let second = modifiedEvents.remove(at: 0)

            switch (first.ad, second.ad) {
            case (.arrival, .departure):
                let day = makeWorkDayFrom(event1: first, event2: second)
                workTimes.append(day)
            case (_, _): continue
            }
        }

        return workTimes
    }

    fileprivate func removeFirstObjectIfDeparture(_ events: [Event]) -> [Event] {
        if events.count > 0 {
            if events.first?.ad == .departure {
                return Array(events.dropFirst(1))
            }
        }
        return events
    }

    fileprivate func makeWorkDayFrom(event1 first: Event, event2 second: Event) -> WorkDay {
        let hoursMinutes = hoursMinutesFromDate(date: first.date, toDate: second.date)
        let workDay = WorkDay(weekDay: first.date.dayOfWeek,
                            hoursWorked: hoursMinutes.hours,
                            minutesWorked: hoursMinutes.minutes,
                            arrivalTime: first.timeString,
                            departureTime: second.timeString)
        return workDay
    }

    func resetDataIfNeeded(_ defaults: UserDefaults = Defaults.standard) {
        if let resetDate = defaults.objectForKey(.ClearDate) as? Date {
            switch resetDate.compare(Date()) {
            case .orderedSame:
                clearEvents()
                updateDefaultResetDate()
            case .orderedAscending:
                clearEvents()
                updateDefaultResetDate()
            case .orderedDescending:
                //time has not yet elapsed do nothing
                print("Week has not yet finished, DO NOT Clear the data")
            }
        }
    }

    var lastArrival: Event? {
        guard let lastArrival = eventsForTheWeek.last, lastArrival.ad == .arrival  else {
            return nil
        }
        return lastArrival
    }

    open func hoursSoFarToday() -> Double {
        if let lastArrival = lastArrival {
            let (h, m) = hoursMinutesFromDate(date: lastArrival.date, toDate: Date())
            let hoursToday = getDoubleFrom(hours: h, min: m)
            return hoursToday
        }
        return 0
    }

}
