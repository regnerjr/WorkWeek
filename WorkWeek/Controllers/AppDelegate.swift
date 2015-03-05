import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    lazy var locationManager:CLLocationManager = {
        var manager = CLLocationManager()
        let auth = CLLocationManager.authorizationStatus()
//        if auth != CLAuthorizationStatus.AuthorizedAlways {
        if auth != CLAuthorizationStatus.Authorized {
            manager.requestAlwaysAuthorization()
        }
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 300
        return manager
    }()

    lazy var workManager: WorkManager = {
        //read from a store, maybe later
        return WorkManager()
    }()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }

}
