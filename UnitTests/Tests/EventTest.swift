import UIKit
import XCTest

class EventTest: XCTestCase {

//    override func setUp() {
//        super.setUp()
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//    
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        super.tearDown()
//    }
//
//    func testExample() {
//        // This is an example of a functional test case.
//        XCTAssert(true, "Pass")
//    }
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock() {
//            // Put the code you want to measure the time of here.
//        }
//    }

    func testEventCreate(){
        let Jan11970 = NSDate(timeIntervalSince1970: 0)
        let newArrival = Event(inOrOut: .Arrival, date: Jan11970)
        XCTAssertEqual(newArrival.date, Jan11970, "Date is stored properly in new Arrival")
        XCTAssertEqual(newArrival.inOrOut, .Arrival, "Arrival is stored as arrival")

        let newDeparture = Event(inOrOut: .Departure, date: Jan11970)
        XCTAssertEqual(newDeparture.date, Jan11970, "Date is stored properly in new Departure")
        XCTAssertEqual(newDeparture.inOrOut, .Departure, "Departure is stored as departure")

    }
}
