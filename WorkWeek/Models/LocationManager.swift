import UIKit
import CoreLocation

/// A manager for handling location realted functions.
public class LocationManager: NSObject {
    /// The actual CLLocationManager
    private var center = NSNotificationCenter.defaultCenter()
    public let manager: CLLocationManager

    /// Dependency Inject Auth Status and Manager for testing
    public init(workManager: WorkManager, authStatus: CLAuthorizationStatus = CLLocationManager.authorizationStatus(), manager: CLLocationManager = CLLocationManager()){
        self.manager = manager
        super.init()
        if authStatus != .AuthorizedAlways {
            manager.requestAlwaysAuthorization()
        }
        configureLocationManager(manager)
        manager.delegate = self
    }

    var monitoredRegions: Set<CLRegion>? {
        return manager.monitoredRegions as! Set<CLRegion>?
    }

    private func configureLocationManager( manager: CLLocationManager ) {
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 200
        manager.pausesLocationUpdatesAutomatically = true
    }

}

extension LocationManager: CLLocationManagerDelegate {
    public func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        let arrivalNotification = NSNotification(name: NotificationCenter.arrival, object: nil)
        center.postNotification(arrivalNotification)
    }
    public func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        let departureNotification = NSNotification(name: NotificationCenter.departure, object: nil)
        center.postNotification(departureNotification)
    }
}

