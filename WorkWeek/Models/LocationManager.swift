import UIKit
import CoreLocation

/// A manager for handling location realted functions.
public class LocationManager: NSObject {
    /// The actual CLLocationManager
    private let center: NSNotificationCenter
    public let manager: CLLocationManager

    /// Dependency Inject Auth Status and Manager for testing
    public init(authStatus: CLAuthorizationStatus = CLLocationManager.authorizationStatus(),
                manager: CLLocationManager = CLLocationManager(),
                center: NSNotificationCenter = NSNotificationCenter.defaultCenter()){
        self.manager = manager
        self.center = center
        super.init()
        if authStatus != .AuthorizedAlways {
            manager.requestAlwaysAuthorization()
        }
        configureLocationManager(manager)
        manager.delegate = self
    }

    /// Returns the regions monitored by the CLLocationManager
    var monitoredRegions: Set<CLRegion>? {
        return manager.monitoredRegions as! Set<CLRegion>?
    }

    /// Sets up the CLLocationManager with the correct defaults
    private func configureLocationManager( manager: CLLocationManager ) {
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 200
        manager.pausesLocationUpdatesAutomatically = true
    }

    public func atWork() -> Bool {
        // Convert monitoredRegions: Set<CLRegion>? => circleRegions: Set<CLCircularRegion>
        // The check each circleRegion to see if we are in it
        if let regions = monitoredRegions, circleRegions = regions as? Set<CLCircularRegion> {
            let inIt = map(circleRegions) { circle -> Bool in
                if let whereAreWeNow = self.manager.location {
                    if circle.containsCoordinate(whereAreWeNow.coordinate) {
                        return true
                    }
                    return false
                }
                return false
            }
            for item in inIt {
                if item == true {
                    return true
                }
            }
        }
        return false
    }

    func startMonitoringRegionAtCoordinate(coord: CLLocationCoordinate2D, withRadius regionRadius: CLLocationDistance) {
        //current limitation: Only one location may be used!!!
        if let regions = monitoredRegions {
            for region in regions {
                manager.stopMonitoringForRegion(region)
            }
        }

        let workRegion = CLCircularRegion(center: coord, radius: regionRadius, identifier: MapRegionIdentifiers.work)
        println("Monitoring new region \(workRegion)")
        manager.startMonitoringForRegion(workRegion)
    }

}

extension LocationManager: CLLocationManagerDelegate {

    /// When a region is entered, an NSNotification is posted to the NSNotification Center
    public func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        let arrivalNotification = NSNotification(name: NotificationCenter.arrival, object: nil)
        center.postNotification(arrivalNotification)
    }

    /// When a region is exited, an NSNotification is posted to the NSNotification Center
    public func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        let departureNotification = NSNotification(name: NotificationCenter.departure, object: nil)
        center.postNotification(departureNotification)
    }
}

