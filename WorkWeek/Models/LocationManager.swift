import UIKit
import CoreLocation

/// A manager for handling location realted functions.
public class LocationManager: NSObject {
    /// The actual CLLocationManager
    public let manager: CLLocationManager
    /// The WorkManager, needed for updating the work week when an arrival or departure happens
    public weak var workManager: WorkManager?

    /// Dependency Inject Auth Status and Manager for testing
    public init(workManager: WorkManager, authStatus: CLAuthorizationStatus = CLLocationManager.authorizationStatus(), manager: CLLocationManager = CLLocationManager()){
        self.manager = manager
        self.workManager = workManager
        super.init()
        if authStatus != .AuthorizedAlways {
            manager.requestAlwaysAuthorization()
        }
        configureLocationManager(manager)
        manager.delegate = self
    }
    deinit{
        workManager = nil
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
        //perhaps this should post a notification since this may be a useful time to update some use and such
        workManager?.addArrival(NSDate())
    }
    public func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        //perhaps this should post a notification since this may be a useful time to update some use and such
        workManager?.addDeparture(NSDate())
    }
}