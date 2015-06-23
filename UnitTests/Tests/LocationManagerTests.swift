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
    override var location: CLLocation? {
        get { return customLocation }
        set { customLocation = newValue}
    }
}

protocol Notifier {
    func addObserver(observer: AnyObject, selector aSelector: Selector,
                     name aName: String?, object anObject: AnyObject?)
    func postNotification(notification: NSNotification)
}

extension NSNotificationCenter : Notifier {}

struct FakeNotificationCenter: Notifier {
    var observerAdded: Bool = false;
    func addObserver(observer: AnyObject, selector aSelector: Selector, name aName: String?, object anObject: AnyObject?) {
        print("Added Observer \(observer) with Selector \(aSelector)")
    }
    var notePosted: NSNotification? = nil
    func postNotification(notification: NSNotification) {
        print("Posted Notification \(notification))")
    }
}

class LocationManagerTests: XCTestCase {

    var locationManager: LocationManager!
    var fakeLocationManager: FakeLocationManager!

    let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), radius: 50, identifier: MapRegionIdentifiers.work)

    override func setUp() {
        fakeLocationManager = FakeLocationManager()
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        locationManager = nil
        fakeLocationManager = nil
    }

    func testLocationManagerSetsUpAManagerIfAuthorized(){

        locationManager = LocationManager(authStatus: CLAuthorizationStatus.AuthorizedAlways,
                                            manager: fakeLocationManager)
        XCTAssertNotNil(locationManager, "LocationManagerIsAllocated if Authorized")
    }

    func testLocationManagerRequestsAlwaysIfNotAllowed(){

        locationManager = LocationManager(authStatus: CLAuthorizationStatus.AuthorizedWhenInUse,
                                            manager: fakeLocationManager)
        XCTAssert(fakeLocationManager.requestedAuthorization == true,
                  "Location Manager requests Always auth if not already granted")

        locationManager = LocationManager(authStatus: CLAuthorizationStatus.Denied,
                                            manager: fakeLocationManager)
        XCTAssert(fakeLocationManager.requestedAuthorization,
                  "Location Manager requests Always Auth if not already authorized")
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

class LocationNotificationTests: XCTestCase {

    var locationManager: LocationManager!
    var fakeLocationManager: FakeLocationManager!
    var fakeNotificationCenter: FakeNotificationCenter

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

    func testNotificationIsSentOnArrival(){
        
    }
}