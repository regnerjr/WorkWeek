import XCTest

import CoreLocation
@testable import WorkWeek

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
    func addObserver(_ observer: Any, selector aSelector: Selector,
                     name aName: NSNotification.Name?, object anObject: Any?)
    func post(_ notification: Notification)
}

extension NotificationCenter : Notifier {}

struct FakeNotificationCenter: Notifier {

    var observerAdded: Bool = false
    func addObserver(_ observer: Any, selector aSelector: Selector,
                     name aName: NSNotification.Name?, object anObject: Any?){
        print("Added Observer \(observer) with Selector \(aSelector)")
    }
    var notePosted: Notification?
    func post(_ notification: Notification) {
        print("Posted Notification \(notification))")
    }
}

class LocationManagerTests: XCTestCase {

    var locationManager: LocationManager!
    var fakeLocationManager: FakeLocationManager!

    let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                                  radius: 50, identifier: MapRegionIdentifiers.work)

    override func setUp() {
        fakeLocationManager = FakeLocationManager()
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        locationManager = nil
        fakeLocationManager = nil
    }

    func testLocationManagerSetsUpAManagerIfAuthorized() {

        locationManager = LocationManager(authStatus: CLAuthorizationStatus.authorizedAlways,
                                            manager: fakeLocationManager)
        XCTAssertNotNil(locationManager, "LocationManagerIsAllocated if Authorized")
    }

    func testLocationManagerRequestsAlwaysIfNotAllowed() {

        locationManager = LocationManager(authStatus: CLAuthorizationStatus.authorizedWhenInUse,
                                            manager: fakeLocationManager)
        XCTAssert(fakeLocationManager.requestedAuthorization == true,
                  "Location Manager requests Always auth if not already granted")

        locationManager = LocationManager(authStatus: CLAuthorizationStatus.denied,
                                            manager: fakeLocationManager)
        XCTAssert(fakeLocationManager.requestedAuthorization,
                  "Location Manager requests Always Auth if not already authorized")
    }
}

class LocationManagerAtWorkTests: XCTestCase {

    var manager: LocationManager!

    override func setUp() {
        manager = LocationManager(authStatus: CLAuthorizationStatus.authorizedAlways)
        super.setUp()
    }
    override func tearDown() {
        super.tearDown()
        manager = nil
    }
    func testNotAtWorkWhenNoRegionsAreDefined() {
        XCTAssertFalse(manager.atWork(), "At Work returns false when no regions are defined")
    }
    func testNotAtWorkWhenLocationNotAuthorized() {
        //use a not authorized Manager
        manager = LocationManager(authStatus: CLAuthorizationStatus.denied)
        XCTAssertFalse(manager.atWork(), "Not at work when location services are off")

        manager = LocationManager(authStatus: CLAuthorizationStatus.notDetermined)
        XCTAssertFalse(manager.atWork(), "Not at work when location services are off")

        manager = LocationManager(authStatus: CLAuthorizationStatus.restricted)
        XCTAssertFalse(manager.atWork(), "Not at work when location services are off")
    }
    func testAtWorkWhenUserLocationInMonitoredRegion() {
        // TODO: Finish This Test
    }
}

class LocationNotificationTests: XCTestCase {

    var locationManager: LocationManager!
    var fakeLocationManager: FakeLocationManager!
    var fakeNotificationCenter: FakeNotificationCenter!

    let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                                  radius: 50, identifier: MapRegionIdentifiers.work)

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

    func testNotificationIsSentOnArrival() {
        // TODO: Finish This Test
    }
}
