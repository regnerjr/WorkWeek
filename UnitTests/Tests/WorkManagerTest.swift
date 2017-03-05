import Foundation
import XCTest

@testable import WorkWeek

class WorkManagerPropertiesTest: XCTestCase {

    var manager: WorkManager!

    override func setUp() {
        clearSavedEventsOnDisk()
        manager = WorkManager()
        super.setUp()
    }
    override func tearDown() {
        //remove any archived data
        manager = nil
        clearSavedEventsOnDisk()
        super.tearDown()
    }

    // Tests eventsForTheWeek, archiving and restoring
    func testEventsEmptyWhenNothingIsArchived() {
        XCTAssertEqual(manager.eventsForTheWeek.count, 0, "No Events on a new manager")
    }

    func testEventsAreRestoredFromArchive() {
        XCTAssertEqual(manager.eventsForTheWeek.count, 0, "No Events")
        manager.addArrival(Date(timeIntervalSinceNow: 0))
        manager = nil
        XCTAssertNil(manager, "Manager is Nil")
        manager = WorkManager() // on creation restores archived events
        XCTAssertEqual(manager.eventsForTheWeek.count, 1, "Has 1 event restored from disk")
    }

    func testHoursWorkedThisWeek() {
        let day1Start = Date(timeIntervalSinceNow: 0)
        let day1End = day1Start.addingTimeInterval(60*60*8)
        manager.addArrival(day1Start)
        manager.addDeparture(day1End)
        XCTAssert(manager.hoursWorkedThisWeek == 8.0, "Worked 8 hours!")

        //add a second day
        let day2start = day1Start.addingTimeInterval(60*60*(24+8))
        let day2end = day2start.addingTimeInterval(60*60*8)
        manager.addArrival(day2start)
        manager.addDeparture(day2end)
        XCTAssert(manager.hoursWorkedThisWeek == 16.0, "Worked 16 Hours")

        //test fractions of an hour add 6 minutes and get 16.1
        let day3start = Date(timeIntervalSinceNow:60*60*(24 + 8) + 1 )
        manager.addArrival(day3start)
//        let time: TimeInterval = 60*60*(24 + 8) + 1 + 60 * 6
        let day3end = day3start.addingTimeInterval( 60 * 6)
        manager.addDeparture(day3end)
        XCTAssert(manager.hoursWorkedThisWeek == 16.1, "Worked 16 Hours and 6 minutes")
    }

    // MARK: - Helper Functions
    func clearSavedEventsOnDisk() {
        let fileManager = FileManager.default
        if let path = Archive.path {
            if fileManager.fileExists(atPath: path) {
                _ = try? fileManager.removeItem(atPath: path)
            }
        }
    }

}

class WorkManagerTest: XCTestCase {

    var manager: WorkManager!

    override func setUp() {
        super.setUp()
        manager = WorkManager()
        manager.clearEvents()
    }

    override func tearDown() {
        //teardown Here
        super.tearDown()
    }

    func testAddArrival() {
        let date = Date()
        manager.addArrival(date)
        let event = manager.eventsForTheWeek.first
        XCTAssertEqual(event!.date, date, "Date is stored in new arrival event")
        XCTAssertEqual(event!.ad, Event.AD.arrival, "Arrival is stored as arrival")
    }

    func testAddDeparture() {
        let date = Date()
        manager.addDeparture(date)
        let event = manager.eventsForTheWeek.first
        XCTAssertEqual(event!.date, date, "Date is stored in new Departure event")
        XCTAssertEqual(event!.ad, Event.AD.departure, "Departure is stored as departure")
    }

    func testIsAtWork() {

        manager.addArrival(Date())
        XCTAssert(manager.isAtWork == true, "User is at work after arriving")
        manager.addDeparture(Date(timeIntervalSinceNow: 60*60*8))
        XCTAssert(manager.isAtWork == false, "User is NOT at work after departing")
    }

    func testClearEvents() {

        manager.addArrival(Date())
        manager.addDeparture(Date(timeIntervalSinceNow: 60*60*8))
        XCTAssert(manager.eventsForTheWeek.count > 0,
                  "Manger has events after arrival and departure have been called")
        manager.clearEvents()
        XCTAssert(manager.eventsForTheWeek.count == 0,
                  "Manager does not have events after they have been cleared")
    }

    func testAllItems() {
        manager.addArrival(Date())
        manager.addDeparture(Date(timeIntervalSinceNow: 60*60*8))
        manager.addArrival(Date(timeIntervalSinceNow: 60*60*24))
        manager.addDeparture(Date(timeIntervalSinceNow: 60*60*(24+8)))
        let days = manager.allItems()
        XCTAssertEqual(days.count, 2, "2 workDays are returned")
    }

    func testMangerProcessesEvents() {

        manager.addArrival(Date())
        manager.addDeparture(Date(timeIntervalSinceNow: 60*60*8))
        XCTAssertEqual(manager.allItems().count, 1,
                       "One arrival and one Departure makes 1 WorkHours")

        manager.addArrival(Date(timeIntervalSinceNow: 60*60*24))
        manager.addDeparture(Date(timeIntervalSinceNow: 60*60*(24+8)))
        XCTAssertEqual(manager.allItems().count, 2, "2 workdays makes 2 WorkHours")

    }

    func testProcessEventsExtended() {

        let startDate = Date()
        manager.addDeparture(startDate) //tets only having a departure, should show no work hours
        let workDays = manager.allItems()
        XCTAssert(workDays.count == 0, "Only a departure, shows 0 workdays")

        manager.addArrival(Date(timeInterval: 60*60*1, since: startDate))
        let workDays1 = manager.allItems()
        XCTAssert(workDays1.count == 0,
                  "One departure followed by an arrival, does not make a work day")

        manager.addDeparture(Date(timeInterval: 60*60*8, since: startDate))
        let workDays2 = manager.allItems()
        XCTAssert(workDays2.count == 1, "Dep, arriv, dep makes 1 work day")
    }

    func testHoursSoFarToday() {
        manager.addArrival(Date(timeInterval: -(60 * 60), since: Date())) // an hour ago
        let hoursToday = manager.hoursSoFarToday()
        XCTAssertEqual(hoursToday, 1.0, "One Hour since arrival")
    }

    func testHoursSoFarToday_notAtWork() {
        manager.addArrival(Date(timeInterval: -(60*60), since: Date()))
        // arrived an hour ago
        manager.addDeparture(Date(timeInterval: -(15*60), since: Date()))
        //departed 15 minutes ago
        let hoursToday = manager.hoursSoFarToday()
        XCTAssertEqual(hoursToday, 0, "No hours today if not at work")

    }

}
