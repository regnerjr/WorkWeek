import UIKit
import XCTest

import WorkWeek

class WorkManagerTest: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testWorkManagerCreation(){
        let manager = WorkManager()
        XCTAssertNotNil(manager, "Manager is not nil")
    }

    func testAddArrival(){
        let manager = WorkManager()
        let date = NSDate()
        let arrival = AD.Arrival
        manager.addArrival(date)
        XCTAssertEqual(manager.eventsForTheWeek[0].date, date, "Date is stored in new arrival event")
        XCTAssertEqual(manager.eventsForTheWeek[0].inOrOut, arrival, "Arrival is stored as arrival")
    }

    func testAddDeparture(){
        let manager = WorkManager()
        let date = NSDate()
        let arrival = AD.Departure
        manager.addDeparture(date)
        XCTAssertEqual(manager.eventsForTheWeek[0].date, date, "Date is stored in new Departure event")
        XCTAssertEqual(manager.eventsForTheWeek[0].inOrOut, AD.Departure, "Departure is stored as departure")
    }


    func testIsAtWork(){
        let manager = WorkManager()

        manager.addArrival(NSDate())
        XCTAssert(manager.isAtWork() == true, "User is at work after arriving")
        manager.addDeparture(NSDate(timeIntervalSinceNow: 60*60*8))
        XCTAssert(manager.isAtWork() == false, "User is NOT at work after departing")
    }

    func testClearEvents(){
        let manager = WorkManager()

        manager.addArrival(NSDate())
        manager.addDeparture(NSDate(timeIntervalSinceNow: 60*60*8))
        XCTAssert(manager.eventsForTheWeek.count > 0, "Manger has events after arrival and departure have been called")
        manager.clearEvents()
        XCTAssert(manager.eventsForTheWeek.count == 0, "Manager does not have events after they have been cleared")
    }

    func testAllItems(){
        //calling all items shoud return an array of work hours objects ready 
        //for placement into a cell in the tableview

    }

    func testMangerProcessesEvents(){

        let manager = WorkManager()
        manager.addArrival(NSDate())
        manager.addDeparture(NSDate(timeIntervalSinceNow: 60*60*8))
        manager.workDays = manager.processEvents(manager.eventsForTheWeek)
        XCTAssertEqual(manager.workDays.count, 1, "One arrival and one Departure makes 1 WorkHours")
        println(manager.workDays)

        manager.addArrival(NSDate(timeIntervalSinceNow: 60*60*24))
        manager.addDeparture(NSDate(timeIntervalSinceNow: 60*60*(24+8)))
        manager.workDays = manager.processEvents(manager.eventsForTheWeek)
        XCTAssertEqual(manager.workDays.count, 2, "2 workdays makes 2 WorkHours")

    }

    func testProcessEventsExtended(){
        let manager = WorkManager()
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

    func testHoursWorkedThisWeek(){
        let manager = WorkManager()
        manager.addArrival(NSDate())
        manager.addDeparture(NSDate(timeIntervalSinceNow: 60*60*8))
        XCTAssert(manager.hoursWorkedThisWeek == 8, "Worked 8 hours!")

        //add a second day
        manager.addArrival(NSDate(timeIntervalSinceNow: 60*60*24))
        manager.addDeparture(NSDate(timeIntervalSinceNow: 60*60*(24+8)))
        XCTAssert(manager.hoursWorkedThisWeek == 16, "Worked 16 Hours")
    }
}

//    func testGetMondayEvents(){
//        let manager = WorkManager()
//        //since we know that Jan 1, 2001 was a monday. We will use that as our reference date.
//        // See tests for NSDateExtension to see why we are setting an explicit time zone.
//        NSTimeZone.setDefaultTimeZone(NSTimeZone(forSecondsFromGMT: 0))
//
//        var events = [
//            NSDate(timeIntervalSinceReferenceDate: 60*60*(24*0+8)),  //8am Jan 1, 2001
//            NSDate(timeIntervalSinceReferenceDate: 60*60*(24*0+16)), //4pm Jan 1, 2001
//            NSDate(timeIntervalSinceReferenceDate: 60*60*(24*1+8)),  //8am Jan 2, 2001
//            NSDate(timeIntervalSinceReferenceDate: 60*60*(24*1+16)), //4pm Jan 2, 2001
//            NSDate(timeIntervalSinceReferenceDate: 60*60*(24*2+8)),  //8am Jan 3, 2001
//            NSDate(timeIntervalSinceReferenceDate: 60*60*(24*2+16)), //4pm Jan 3, 2001
//            NSDate(timeIntervalSinceReferenceDate: 60*60*(24*3+8)),  //8am Jan 4, 2001
//            NSDate(timeIntervalSinceReferenceDate: 60*60*(24*3+16)), //4pm Jan 4, 2001
//            NSDate(timeIntervalSinceReferenceDate: 60*60*(24*4+8)),  //8am Jan 5, 2001
//            NSDate(timeIntervalSinceReferenceDate: 60*60*(24*4+16)), //4pm Jan 5, 2001
//        ]
//
//        manager.addArrival(  events[0])
//        manager.addDeparture(events[1])
//        manager.addArrival(  events[2])
//        manager.addDeparture(events[3])
//        manager.addArrival(  events[4])
//        manager.addDeparture(events[5])
//        manager.addArrival(  events[6])
//        manager.addDeparture(events[7])
//        manager.addArrival(  events[8])
//        manager.addDeparture(events[9])
//        let monday = manager.getMondayEvents()
//        let mondayFakeEvents =
//            [Event(inOrOut: .Arrival,   date: events[0]),
//             Event(inOrOut: .Departure, date: events[1])]
////        XCTAssertEqual(mondayFakeEvents, monday, "Correctly Fetched Mondays Events")
//        XCTAssertEqual(mondayFakeEvents[0], monday[0], "Correctly fetched Mondays Events")
//        XCTAssertEqual(mondayFakeEvents[1], monday[1], "Correctly fetched Mondays Events")
//    }
//    func testGetFirstPair(){
//
//        let manager = WorkManager()
//        //since we know that Jan 1, 2001 was a monday. We will use that as our reference date.
//        // See tests for NSDateExtension to see why we are setting an explicit time zone.
//        NSTimeZone.setDefaultTimeZone(NSTimeZone(forSecondsFromGMT: 0))
//
//        var events = [
//            NSDate(timeIntervalSinceReferenceDate: 60*60*(24*0+8)),  //8am Jan 1, 2001
//            NSDate(timeIntervalSinceReferenceDate: 60*60*(24*0+16)), //4pm Jan 1, 2001
//            NSDate(timeIntervalSinceReferenceDate: 60*60*(24*1+16)), //4pm Jan 2, 2001
//            NSDate(timeIntervalSinceReferenceDate: 60*60*(24*2+8)),  //8am Jan 3, 2001
//        ]
//
//        manager.addArrival(  events[0])
//        manager.addDeparture(events[1])
//        manager.addArrival(  events[2])
//        manager.addDeparture(events[3])
//
//        let firstPair = manager.getFirstPair()
//
//    }
//