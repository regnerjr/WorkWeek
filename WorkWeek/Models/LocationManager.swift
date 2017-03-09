import UIKit
import CoreLocation

/// A manager for handling location realted functions.
class LocationManager: NSObject {

    var manager: CLLocationManager

    init(authStatus: CLAuthorizationStatus = CLLocationManager.authorizationStatus(),
         manager: CLLocationManager = CLLocationManager(),
         locationDelegate: CLLocationManagerDelegate) {
        self.manager = manager
        super.init()

        if authStatus != .authorizedAlways {
            manager.requestAlwaysAuthorization()
        }
        configureLocationManager(manager)
        manager.delegate = locationDelegate
    }

    /// Returns the regions monitored by the CLLocationManager
    /// currently restricted to circular regions only
    var monitoredRegions: Set<CLCircularRegion> {
        return Set<CLCircularRegion>(manager.monitoredRegions
                                        .flatMap { $0 as? CLCircularRegion })
    }

    var userLocation: CLLocation? {
        return manager.location
    }

    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }

    /// Sets up the CLLocationManager with the correct defaults
    fileprivate func configureLocationManager( _ manager: CLLocationManager ) {
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 200
        manager.pausesLocationUpdatesAutomatically = true
    }

    func atWork() -> Bool {
        guard let currentLocation = userLocation else {
            return false // don't know where you are, can't tell if you're at work
        }
        return monitoredRegions.contains { (circle: CLCircularRegion) -> Bool in
            return circle.contains(currentLocation.coordinate)
        }
    }

    func startMonitoringRegionAtCoordinate(_ coord: CLLocationCoordinate2D,
                                           withRadius regionRadius: CLLocationDistance) {
        //current limitation: Only one location may be used!!!
        monitoredRegions.forEach { region in
            manager.stopMonitoring(for: region)
        }

        let workRegion = CLCircularRegion(center: coord, radius: regionRadius,
                                          identifier: MapRegionIdentifiers.work)
        print("Monitoring new region \(workRegion)")
        manager.startMonitoring(for: workRegion)
    }

}
