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

    override var monitoredRegions: Set<CLRegion> {
        return [CLCircularRegion(center:
            CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), radius: 10, identifier: "FakeRegion") ]
    }

    var startedUpdatingLocation = false
    override func startUpdatingLocation() {
        startedUpdatingLocation = true
    }
}

class FakeLocationManagerNoRegions: CLLocationManager {
    override var monitoredRegions: Set<CLRegion> {
        return []
    }
}
class FakeLocationManagerNoLocation: CLLocationManager {
    override var location: CLLocation? {
        return nil
    }
}

class FakeLocationManagerUserNotInRegion: CLLocationManager {
    override var monitoredRegions: Set<CLRegion> {
        return [CLCircularRegion(center:
            CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
                                 radius: 10, identifier: "FakeRegion") ]
    }
    override var location: CLLocation? {
        return CLLocation(latitude: 1.0, longitude: 1.0)
    }
}

class FakeLocationManagerUserInRegion: CLLocationManager {
    override var monitoredRegions: Set<CLRegion> {
        return [CLCircularRegion(center:
            CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
                                 radius: 10, identifier: "FakeRegion") ]
    }
    override var location: CLLocation? {
        return CLLocation(latitude: 0.0, longitude: 0.0)
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
                     name aName: NSNotification.Name?, object anObject: Any?) {
        print("Added Observer \(observer) with Selector \(aSelector)")
    }
    var notePosted: Notification?
    func post(_ notification: Notification) {
        print("Posted Notification \(notification))")
    }
}

class MockLocationDelegate: NSObject, CLLocationManagerDelegate {}

class LocationManagerTests: XCTestCase {

    var locationManager: LocationManager!
    var fakeLocationManager: FakeLocationManager!

    let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                                  radius: 50, identifier: MapRegionIdentifiers.work)

    let mockLocDel = MockLocationDelegate()

    override func setUp() {
        fakeLocationManager = FakeLocationManager()
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        locationManager = nil
        fakeLocationManager = nil
    }

    func testLocationManagerSkipsAskIfAuthorized() {

        locationManager = LocationManager(authStatus: CLAuthorizationStatus.authorizedAlways,
                                          manager: fakeLocationManager, locationDelegate: mockLocDel)
        XCTAssert(fakeLocationManager.requestedAuthorization == false,
                  "Don't ask for location if we already have it")
    }

    func testLocationManagerRequestsAlwaysIfNotAllowed() {

        locationManager = LocationManager(authStatus: CLAuthorizationStatus.authorizedWhenInUse,
                                            manager: fakeLocationManager, locationDelegate: mockLocDel)
        XCTAssert(fakeLocationManager.requestedAuthorization == true,
                  "Location Manager requests Always auth if not already granted")

        locationManager = LocationManager(authStatus: CLAuthorizationStatus.denied,
                                            manager: fakeLocationManager, locationDelegate: mockLocDel)
        XCTAssert(fakeLocationManager.requestedAuthorization,
                  "Location Manager requests Always Auth if not already authorized")
    }

    func testManagerManagesCLLocationsRegisteredRegions() {
        locationManager = LocationManager(authStatus: CLAuthorizationStatus.authorizedWhenInUse,
                                          manager: fakeLocationManager, locationDelegate: mockLocDel)
        let regions = locationManager.monitoredRegions

        XCTAssert(regions.count == 1)
        XCTAssert(regions.first!.identifier == "FakeRegion")
    }

    func testWeCanStartUpdatingLocation() {
        locationManager = LocationManager(authStatus: CLAuthorizationStatus.authorizedWhenInUse,
                                          manager: fakeLocationManager, locationDelegate: mockLocDel)
        locationManager.startUpdatingLocation()
        XCTAssert(fakeLocationManager.startedUpdatingLocation == true)
    }

    func testCantBeAtWorkIfThereAreNoRegionsDefined() {
        let noRegions = FakeLocationManagerNoRegions()
        locationManager = LocationManager(authStatus: CLAuthorizationStatus.authorizedWhenInUse,
                                          manager: noRegions, locationDelegate: mockLocDel)
        XCTAssert(locationManager.atWork() == false)
    }

    func testCantBeAtWorkIfWeDontKnowWhereYouAre() {
        let noLocation = FakeLocationManagerNoLocation()
        locationManager = LocationManager(authStatus: CLAuthorizationStatus.authorizedWhenInUse,
                                          manager: noLocation, locationDelegate: mockLocDel)
        XCTAssert(locationManager.atWork() == false)
    }

    func testReportsNotInRegionIfUserNotInRegion() {
        let notInRegion = FakeLocationManagerUserNotInRegion()
        locationManager = LocationManager(authStatus: CLAuthorizationStatus.authorizedWhenInUse,
                                          manager: notInRegion, locationDelegate: mockLocDel)
        XCTAssert(locationManager.atWork() == false)
    }

    func testReportsInRegionIfUserInRegion() {
        let InRegion = FakeLocationManagerUserInRegion()
        locationManager = LocationManager(authStatus: CLAuthorizationStatus.authorizedWhenInUse,
                                          manager: InRegion, locationDelegate: mockLocDel)
        XCTAssert(locationManager.atWork() == true)
    }
}

class LocationManagerAtWorkTests: XCTestCase {

    var manager: LocationManager!
    let mockLocDel = MockLocationDelegate()

    override func setUp() {
        manager = LocationManager(authStatus: CLAuthorizationStatus.authorizedAlways, locationDelegate: mockLocDel)
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
        manager = LocationManager(authStatus: CLAuthorizationStatus.denied, locationDelegate: mockLocDel)
        XCTAssertFalse(manager.atWork(), "Not at work when location services are off")

        manager = LocationManager(authStatus: CLAuthorizationStatus.notDetermined, locationDelegate: mockLocDel)
        XCTAssertFalse(manager.atWork(), "Not at work when location services are off")

        manager = LocationManager(authStatus: CLAuthorizationStatus.restricted, locationDelegate: mockLocDel)
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
