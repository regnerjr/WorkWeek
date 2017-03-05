import XCTest

@testable import WorkWeek

class EventTest: XCTestCase {

    func testEventCreate() {
        let Jan11970 = Date(timeIntervalSince1970: 0)
        let newArrival = Event(ad: .arrival, date: Jan11970)
        XCTAssertEqual(newArrival.date, Jan11970, "Date is stored properly in new Arrival")
        XCTAssertEqual(newArrival.ad, Event.AD.arrival, "Arrival is stored as arrival")

        let newDeparture = Event(ad: .departure, date: Jan11970)
        XCTAssertEqual(newDeparture.date, Jan11970, "Date is stored properly in new Departure")
        XCTAssertEqual(newDeparture.ad, Event.AD.departure, "Departure is stored as departure")

    }

    func testEventEquatable() {
        let date = Date()

        let event1 = Event(ad: .arrival, date: date)
        let event2 = Event(ad: .arrival, date: date)
        XCTAssert(event1 == event2, "2 distinct events can be equal")

        let event3 = Event(ad: .departure, date: date)
        XCTAssertFalse(event1 == event3, "Event equality is based on Arival Departure Status")

        let event4 = Event(ad: .departure, date: Date(timeIntervalSinceReferenceDate: 0))
        XCTAssertFalse(event1 == event4, "Event equality is based on date")
    }

    func testEventArchive() {

        let Jan11970 = Date(timeIntervalSince1970: 0)
        let newArrival = Event(ad: .arrival, date: Jan11970)

        let data = NSMutableData(capacity: 300) //make a data
        if let data = data {

        let coder = NSKeyedArchiver(forWritingWith: data)
        let encoded = EncodeEvent(event: newArrival)
        encoded.encode(with: coder)
        coder.finishEncoding()

        let decoder = NSKeyedUnarchiver(forReadingWith: data as Data)
        let restored = EncodeEvent(coder: decoder)?.value

        XCTAssert(restored! == newArrival, "Restored Event is same as original event")

        }
    }

}
