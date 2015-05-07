import UIKit
import XCTest

import WorkWeek

class WorkManagerPropertiesTest: XCTestCase {

    override func setUp() {
        clearSavedEvents()
        super.setUp()
    }
    override func tearDown() {
        //remove any archived data
        clearSavedEvents()
        super.tearDown()
    }

    // Tests eventsForTheWeek, archiving and restoring
    func testEventsEmptyWhenNothingIsArchived(){
        let manager = WorkManager()
        XCTAssertEqual(manager.eventsForTheWeek.count, 0, "No Events on a new manager")
    }

    func testEventsAreRestoredFromArchive(){
        var manager: WorkManager! = WorkManager()
        XCTAssertEqual(manager.eventsForTheWeek.count, 0, "No Events")
        manager.addArrival(NSDate())
        manager = nil
        XCTAssertNil(manager, "Manager is Nil")
        manager = WorkManager() // on creation restores archived events
        XCTAssertEqual(manager.eventsForTheWeek.count, 1, "Has 1 event restored from disk")
    }

    func testHoursWorkedThisWeek(){
        var manager = WorkManager()
        manager.addArrival(NSDate())
        manager.addDeparture(NSDate(timeIntervalSinceNow: 60*60*8))
        XCTAssert(manager.hoursWorkedThisWeek == 8.0, "Worked 8 hours!")

        //add a second day
        manager.addArrival(NSDate(timeIntervalSinceNow:   60*60*24))
        manager.addDeparture(NSDate(timeIntervalSinceNow: 60*60*(24+8)))
        XCTAssert(manager.hoursWorkedThisWeek == 16.0, "Worked 16 Hours")

        //test fractions of an hour add 6 minutes and get 16.1
        manager.addArrival(NSDate(timeIntervalSinceNow:   60*60*(24 + 8) + 1 ))
        manager.addDeparture(NSDate(timeIntervalSinceNow: 60*60*(24 + 8) + 1 + 60 * 6))
        XCTAssert(manager.hoursWorkedThisWeek == 16.1, "Worked 16 Hours and 6 minutes")
    }

    // MARK: - Helper Functions
    func clearSavedEvents(){
        let documentsDirectories = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,
            NSSearchPathDomainMask.UserDomainMask, true) as? [String]
        let path = documentsDirectories!.first! + "/items.archive"
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(path) {
        var error: NSError? = nil
        fileManager.removeItemAtPath(path, error: &error)
        }
    }

}

class WorkManagerTest: XCTestCase {

    var manager: WorkManager!

    override func setUp(){
        super.setUp()
        manager = WorkManager()
        manager.clearEvents()
    }

    override func tearDown(){
        //teardown Here
        super.tearDown()
    }

    func testAddArrival(){
        let date = NSDate()
        let arrival = AD.Arrival
        manager.addArrival(date)
        let event = manager.eventsForTheWeek.objectAtIndex(0) as! Event
        XCTAssertEqual(event.date, date, "Date is stored in new arrival event")
        XCTAssertEqual(event.inOrOut, arrival, "Arrival is stored as arrival")
    }

    func testAddDeparture(){
        let date = NSDate()
        let arrival = AD.Departure
        manager.addDeparture(date)
        let event = manager.eventsForTheWeek.objectAtIndex(0) as! Event
        XCTAssertEqual(event.date, date, "Date is stored in new Departure event")
        XCTAssertEqual(event.inOrOut, AD.Departure, "Departure is stored as departure")
    }


    func testIsAtWork(){

        manager.addArrival(NSDate())
        XCTAssert(manager.isAtWork == true, "User is at work after arriving")
        manager.addDeparture(NSDate(timeIntervalSinceNow: 60*60*8))
        XCTAssert(manager.isAtWork == false, "User is NOT at work after departing")
    }

    func testClearEvents(){

        manager.addArrival(NSDate())
        manager.addDeparture(NSDate(timeIntervalSinceNow: 60*60*8))
        XCTAssert(manager.eventsForTheWeek.count > 0, "Manger has events after arrival and departure have been called")
        manager.clearEvents()
        XCTAssert(manager.eventsForTheWeek.count == 0, "Manager does not have events after they have been cleared")
    }

    func testAllItems(){
        manager.addArrival(NSDate())
        manager.addDeparture(NSDate(timeIntervalSinceNow: 60*60*8))
        manager.addArrival(NSDate(timeIntervalSinceNow: 60*60*24))
        manager.addDeparture(NSDate(timeIntervalSinceNow: 60*60*(24+8)))
        let days = manager.allItems()
        XCTAssertEqual(days.count, 2, "2 workDays are returned")
    }

    func testMangerProcessesEvents(){

        manager.addArrival(NSDate())
        manager.addDeparture(NSDate(timeIntervalSinceNow: 60*60*8))
        XCTAssertEqual(manager.allItems().count, 1, "One arrival and one Departure makes 1 WorkHours")

        manager.addArrival(NSDate(timeIntervalSinceNow: 60*60*24))
        manager.addDeparture(NSDate(timeIntervalSinceNow: 60*60*(24+8)))
        XCTAssertEqual(manager.allItems().count, 2, "2 workdays makes 2 WorkHours")

    }

    func testProcessEventsExtended(){

        let startDate = NSDate()
        manager.addDeparture(startDate) //tets only having a departure, should show no work hours
        let workDays = manager.allItems()
        XCTAssert(workDays.count == 0, "Only a departure, shows 0 workdays")

        manager.addArrival(NSDate(timeInterval: 60*60*1, sinceDate: startDate))
        let workDays1 = manager.allItems()
        XCTAssert(workDays1.count == 0, "One departure followed by an arrival, does not make a work day")

        manager.addDeparture(NSDate(timeInterval: 60*60*8, sinceDate: startDate))
        let workDays2 = manager.allItems()
        XCTAssert(workDays2.count == 1, "Dep, arriv, dep makes 1 work day")
    }

    func testHourMinuteCalculations(){

        let referenceDate = NSDate(timeIntervalSinceReferenceDate: 0)
        let twoHours = NSDate(timeIntervalSinceReferenceDate: 60*60*2)
        let timeDiff = hoursMinutesFromDate(date: referenceDate, toDate: twoHours)
        XCTAssert(timeDiff.hours == 2, "Time difference of 2 hours is calculated correctly")
        XCTAssert(timeDiff.minutes == 0, "Time difference of 2 hours is calculated correctly")

        let twoAndAHalf = NSDate(timeIntervalSinceReferenceDate: 60*60*2 + 60*30)
        let timeDiff2 = hoursMinutesFromDate(date: referenceDate, toDate: twoAndAHalf)
        XCTAssert(timeDiff2.hours == 2, "Time diff of 2hour 30 minutes is calculated")
        XCTAssert(timeDiff2.minutes == 30 , "Time diff of 2hour 30 minutes is calculated")
    }

}