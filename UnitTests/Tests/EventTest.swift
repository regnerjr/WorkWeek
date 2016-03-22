import XCTest

@testable import WorkWeek

class EventTest: XCTestCase {

    func testEventCreate() {
        let Jan11970 = NSDate(timeIntervalSince1970: 0)
        let newArrival = Event(ad: .Arrival, date: Jan11970)
        XCTAssertEqual(newArrival.date, Jan11970, "Date is stored properly in new Arrival")
        XCTAssertEqual(newArrival.ad, Event.AD.Arrival, "Arrival is stored as arrival")

        let newDeparture = Event(ad: .Departure, date: Jan11970)
        XCTAssertEqual(newDeparture.date, Jan11970, "Date is stored properly in new Departure")
        XCTAssertEqual(newDeparture.ad, Event.AD.Departure, "Departure is stored as departure")

    }

    func testEventEquatable() {
        let date = NSDate()

        let event1 = Event(ad: .Arrival, date: date)
        let event2 = Event(ad: .Arrival, date: date)
        XCTAssert(event1 == event2, "2 distinct events can be equal")

        let event3 = Event(ad: .Departure, date: date)
        XCTAssertFalse(event1 == event3, "Event equality is based on Arival Departure Status")

        let event4 = Event(ad: .Departure, date: NSDate(timeIntervalSinceReferenceDate: 0))
        XCTAssertFalse(event1 == event4, "Event equality is based on date")
    }

    func testEventArchive() {

        let Jan11970 = NSDate(timeIntervalSince1970: 0)
        let newArrival = Event(ad: .Arrival, date: Jan11970)


        let data = NSMutableData(capacity: 300) //make a data
        if let data = data {

        let coder = NSKeyedArchiver(forWritingWithMutableData: data)
        let encoded = EncodeEvent(ev: newArrival)
        encoded.encodeWithCoder(coder)
        coder.finishEncoding()

        let decoder = NSKeyedUnarchiver(forReadingWithData: data)
        let restored = EncodeEvent(coder: decoder)?.value


        XCTAssert(restored! == newArrival, "Restored Event is same as original event")

        }
    }

}
