import UIKit
import XCTest

import CoreLocation
import WorkWeek

class FakeManager: CLLocationManager {
    var requestedAuthorization = false
    override func requestAlwaysAuthorization() {
        requestedAuthorization = true
    }
}

class FakeWorkManager: WorkManager {
    var addedArrival = false
    var addedDeparture = false

    override func addArrival(date: NSDate) {
        addedArrival = true
        super.addArrival(date)
    }
    override func addDeparture(date: NSDate) {
        addedDeparture = true
        super.addDeparture(date)
    }
}

class LocationManagerTests: XCTestCase {

    var locationManager: LocationManager!
    var fakeManager: FakeManager!
    var fakeWorkManager: FakeWorkManager!
    let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), radius: 50, identifier: MapRegionIdentifiers.work)

    override func setUp() {
        fakeManager = FakeManager()
        fakeWorkManager = FakeWorkManager()
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        locationManager = nil
        fakeManager = nil
        fakeWorkManager = nil
    }

    

    func testLocationManagerSetsUpAManagerIfAuthorized(){
        locationManager = LocationManager(workManager: fakeWorkManager, authStatus: CLAuthorizationStatus.AuthorizedAlways, manager: fakeManager)
        XCTAssertNotNil(locationManager, "LocationManagerIsAllocated if Authorized")
    }

    func testLocationManagerRequestsAlwaysIfNotAllowed(){
        locationManager = LocationManager(workManager: fakeWorkManager, authStatus: CLAuthorizationStatus.AuthorizedWhenInUse, manager: fakeManager)
        XCTAssert(fakeManager.requestedAuthorization == true, "Location Manager requests Always auth if not already granted")

        locationManager = LocationManager(workManager: fakeWorkManager, authStatus: CLAuthorizationStatus.Denied, manager: fakeManager)
        XCTAssert(fakeManager.requestedAuthorization, "Location Manager requests Always Auth if not already authorized")
    }

    func testAddsEventToWorkManagerOnEnterRegion(){
        XCTAssert(fakeWorkManager.addedArrival == false, "Added arrival is false before arrival")
        locationManager = LocationManager(workManager: fakeWorkManager)
        locationManager.locationManager(locationManager.manager, didEnterRegion: region)
        XCTAssert(fakeWorkManager.addedArrival, "Adds Arrival when called back by the CLLocationManager")
    }

    func testAddsEventToWorkManagerOnExitRegion(){
        XCTAssert(fakeWorkManager.addedDeparture == false, "Added departure is false befor you leave")
        locationManager = LocationManager(workManager: fakeWorkManager)
        locationManager.locationManager(locationManager.manager, didExitRegion: region)
        XCTAssert(fakeWorkManager.addedDeparture, "Adds Arrival when called back by the CLLocationManager")
    }

}
