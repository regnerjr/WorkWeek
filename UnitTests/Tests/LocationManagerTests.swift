import UIKit
import XCTest

import CoreLocation
import WorkWeek

class FakeLocationManager: CLLocationManager {
    var requestedAuthorization = false
    override func requestAlwaysAuthorization() {
        requestedAuthorization = true
    }
    var customLocation: CLLocation! = nil
    override var location: CLLocation {
        get { return customLocation }
        set { customLocation = newValue}
    }
}

class FakeNotificationCenter: NSNotificationCenter {
    var observer: AnyObject! = nil
    var selector: Selector = ""
    var note: NSNotification! = nil
    override func addObserver(observer: AnyObject, selector aSelector: Selector, name aName: String?, object anObject: AnyObject?) {
        self.observer = observer
        self.selector = aSelector
        super.addObserver(observer, selector: aSelector, name: aName, object: anObject)
    }
    override func postNotification(notification: NSNotification) {
        note = notification
        super.postNotification(notification)
    }
}

class LocationManagerTests: XCTestCase {

    var locationManager: LocationManager!
    var fakeLocationManager: FakeLocationManager!
    var fakeNotificationCenter: FakeNotificationCenter!

    let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), radius: 50, identifier: MapRegionIdentifiers.work)

    override func setUp() {
        fakeLocationManager = FakeLocationManager()
        fakeNotificationCenter = FakeNotificationCenter()
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        locationManager = nil
        fakeLocationManager = nil
        fakeNotificationCenter = nil
    }

    func testLocationManagerSetsUpAManagerIfAuthorized(){

        locationManager = LocationManager(authStatus: CLAuthorizationStatus.AuthorizedAlways,
                                            manager: fakeLocationManager,
                                            center: fakeNotificationCenter)
        XCTAssertNotNil(locationManager, "LocationManagerIsAllocated if Authorized")
    }

    func testLocationManagerRequestsAlwaysIfNotAllowed(){

        locationManager = LocationManager(authStatus: CLAuthorizationStatus.AuthorizedWhenInUse,
                                            manager: fakeLocationManager,
                                            center: fakeNotificationCenter)
        XCTAssert(fakeLocationManager.requestedAuthorization == true,
                  "Location Manager requests Always auth if not already granted")

        locationManager = LocationManager(authStatus: CLAuthorizationStatus.Denied,
                                            manager: fakeLocationManager,
                                            center: fakeNotificationCenter)
        XCTAssert(fakeLocationManager.requestedAuthorization,
                  "Location Manager requests Always Auth if not already authorized")
    }

    //MARK: - Notifications are Posted on arrival and Departure
    func testAddsEventPostsNotification(){
        
        XCTAssertNil(fakeNotificationCenter.observer, "Notificaiton observer is nil before it is posted")
        locationManager = LocationManager(center: fakeNotificationCenter)
        locationManager.locationManager(locationManager.manager, didEnterRegion: region)
        XCTAssert(fakeNotificationCenter.note.name == "ArrivalNotificationKey", "Notification is posted if region is entered")
    }

    func testAddsEventToWorkManagerOnExitRegion(){
        XCTAssertNil(fakeNotificationCenter.observer, "Notification observer is nil before it is posted")
        locationManager = LocationManager(center: fakeNotificationCenter)
        locationManager.locationManager(locationManager.manager, didExitRegion: region)
        XCTAssert(fakeNotificationCenter.note.name == "DepartureNotificationKey", "Note is posted")
    }

}

class LocationManagerAtWorkTests: XCTestCase {

    var manager: LocationManager!

    override func setUp() {
        manager = LocationManager(authStatus: CLAuthorizationStatus.AuthorizedAlways)
        super.setUp()
    }
    override func tearDown() {
        super.tearDown()
        manager = nil
    }
    func testNotAtWorkWhenNoRegionsAreDefined(){
        XCTAssertFalse(manager.atWork(), "At Work returns false when no regions are defined")
    }
    func testNotAtWorkWhenLocationNotAuthorized(){
        //use a not authorized Manager
        manager = LocationManager(authStatus: CLAuthorizationStatus.Denied)
        XCTAssertFalse(manager.atWork(), "Not at work when location services are off")

        manager = LocationManager(authStatus: CLAuthorizationStatus.NotDetermined)
        XCTAssertFalse(manager.atWork(), "Not at work when location services are off")

        manager = LocationManager(authStatus: CLAuthorizationStatus.Restricted)
        XCTAssertFalse(manager.atWork(), "Not at work when location services are off")
    }
    func testAtWorkWhenUserLocationInMonitoredRegion(){
        
    }
}
