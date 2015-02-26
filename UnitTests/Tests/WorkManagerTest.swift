import UIKit
import XCTest

class WorkManagerTest: XCTestCase {

//    override func setUp() {
//        super.setUp()
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

}