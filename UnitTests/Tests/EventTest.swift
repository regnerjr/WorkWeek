import UIKit
import XCTest

import WorkWeek

class EventTest: XCTestCase {

    func testEventCreate(){
        let Jan11970 = NSDate(timeIntervalSince1970: 0)
        let newArrival = Event(inOrOut: .Arrival, date: Jan11970)
        XCTAssertEqual(newArrival.date, Jan11970, "Date is stored properly in new Arrival")
        XCTAssertEqual(newArrival.inOrOut, AD.Arrival, "Arrival is stored as arrival")

        let newDeparture = Event(inOrOut: .Departure, date: Jan11970)
        XCTAssertEqual(newDeparture.date, Jan11970, "Date is stored properly in new Departure")
        XCTAssertEqual(newDeparture.inOrOut, AD.Departure, "Departure is stored as departure")

    }

    func testEventEquatable(){
        let date = NSDate()

        let event1 = Event(inOrOut: .Arrival, date: date)
        let event2 = Event(inOrOut: .Arrival, date: date)
        XCTAssert(event1 == event2, "2 distinct events can be equal")

        let event3 = Event(inOrOut: .Departure, date: date)
        XCTAssertFalse(event1 == event3, "Event equality is based on Arival Departure Status")

        let event4 = Event(inOrOut: .Departure, date: NSDate(timeIntervalSinceReferenceDate: 0))
        XCTAssertFalse(event1 == event4, "Event equality is based on date")
    }
    
}
