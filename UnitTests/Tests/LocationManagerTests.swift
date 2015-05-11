import UIKit
import XCTest

import CoreLocation
import WorkWeek

class LocationManagerTests: XCTestCase {

//    var locationManager: LocationManager!

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testLocationManagerSetsUpAManagerIfAuthorized(){
        let locationManager = LocationManager(authStatus: CLAuthorizationStatus.AuthorizedAlways)
        XCTAssertNotNil(locationManager, "LocationManagerIsAllocated if Authorized")
    }

    func testLocationManager_DOES_NOT_SetUpAManagerIf_NOT_Authorized(){
        let locationManager = LocationManager(authStatus: CLAuthorizationStatus.AuthorizedWhenInUse)
        XCTAssertNil(locationManager.manager, "Manger not allocated when auth status is When in Use")

        let manager2 = LocationManager(authStatus: CLAuthorizationStatus.Denied)
        XCTAssertNil(locationManager, "Location Manager is nil if Denied Location Use")
    }

    func testExample() {
        XCTAssert(true, "Pass")
    }
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock() {
//        }
//    }

}
