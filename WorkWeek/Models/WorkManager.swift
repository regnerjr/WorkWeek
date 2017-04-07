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

class WorkManager: NSObject {

    fileprivate(set) var eventsForTheWeek = [Event]() {
        willSet {
            print("Events for the week Will Set did fire:")
            print("New Value: \(newValue)")
        }
    }

    var localNotificationHandler = LocalNotifier()

    fileprivate var workDays = [WorkDay]()

    var hoursWorkedThisWeek: Double {
        let hoursWorked = workDays.reduce(0, {$0 + $1.hoursWorked})
        let hourFractions = workDays.reduce(0, {$0 + $1.minutesWorked})
        return Double(hoursWorked) + Double(hourFractions) / 60.0
    }

    var hoursInWorkWeek: Int {
        return Defaults.standard.integerForKey(.HoursInWorkWeek)
    }

    var isAtWork: Bool {
        guard let event = eventsForTheWeek.last else {
            return false //never been there not there now
        }
        switch event.ad {
        case .arrival: return true
        case .departure: return false
        }
    }

    // MARK: - Init
    override init() {
        super.init()
        eventsForTheWeek = restoreArchivedEvents() ?? [Event]()
        print("WorkManager - Init \(self)")
    }

    deinit {
        print("WorkManager - Deinit \(self)")
    }

    func addArrival(_ date: Date = Date()) {

        localNotificationHandler.setupNotification(hoursWorkedThisWeek,
                                                   hoursInFullWorkWeek: hoursInWorkWeek)
        let newArrival = Event(ad: .arrival, date: date)
        eventsForTheWeek.append(newArrival)
        postWorkWeekChangedNotification()

        saveNewArchive(eventsForTheWeek)
    }

    func addDeparture(_ date: Date = Date()) {
        localNotificationHandler.cancelAllNotifications()
        let departure = Event(ad: .departure, date: date)
        eventsForTheWeek.append(departure)

        postWorkWeekChangedNotification()
        saveNewArchive(eventsForTheWeek)
        workDays = processEvents(eventsForTheWeek)

    }

    func clearEvents() {
        eventsForTheWeek = [Event]()
        postWorkWeekChangedNotification()
        //clear the archive as well
        saveNewArchive(eventsForTheWeek)
    }

    func addArrivalIfAtWork(_ locationManager: LocationManager) {
        //if you are currently at work add an arrival right now.
        if locationManager.atWork() {
            addArrival()
        }
    }

    func postWorkWeekChangedNotification(_ center: NotificationCenter = NotificationCenter.default) {
        let note = Notification(name: Notification.Name(rawValue: "WorkWeekUpdated"), object: nil)
        center.post(note)
    }

    private func restoreArchivedEvents() -> [Event]? {
        return NSKeyedUnarchiver.unarchiveMutableArrayWithFile(Archive.path)?
            .flatMap { $0 as? EncodeEvent}
            .map { $0.value }
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

    func allItems() -> [WorkDay] {
        return processEvents(eventsForTheWeek)
    }

    func processEvents(_ inEvents: [Event] ) -> [WorkDay] {
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

    func hoursSoFarToday() -> Double {
        if let lastArrival = lastArrival {
            let (h, m) = hoursMinutesFromDate(date: lastArrival.date, toDate: Date())
            let hoursToday = getDoubleFrom(hours: h, min: m)
            return hoursToday
        }
        return 0
    }
}

import CoreLocation

extension WorkManager: CLLocationManagerDelegate {

    /// When a region is entered, an NSNotification is posted to the NSNotification Center
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("LocationDelegate - Adding Arrival")
        addArrival()
    }

    /// When a region is exited, an NSNotification is posted to the NSNotification Center
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("LocationDelegate - Adding Departure")
        addDeparture()
    }
}
