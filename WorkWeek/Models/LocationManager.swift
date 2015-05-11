import UIKit
import CoreLocation

public class LocationManager: NSObject {

    public var manager: CLLocationManager?

    public init(authStatus: CLAuthorizationStatus = CLLocationManager.authorizationStatus()){
        super.init()
        if authStatus == .AuthorizedAlways {
            manager = configureLocationManager()
            manager?.delegate = self
        }
    }

    var monitoredRegions: Set<CLRegion>? {
        return manager?.monitoredRegions as! Set<CLRegion>?
    }

    func configureLocationManager() -> CLLocationManager{
        var manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 200
        manager.pausesLocationUpdatesAutomatically = true
        return manager
    }

}

extension LocationManager: CLLocationManagerDelegate {

}