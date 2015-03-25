import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    lazy var locationManager:CLLocationManager = {
        var manager = CLLocationManager()
        let auth = CLLocationManager.authorizationStatus()
        if auth != CLAuthorizationStatus.AuthorizedAlways {
            manager.requestAlwaysAuthorization()
        }
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 200
        manager.pausesLocationUpdatesAutomatically = true
        return manager
    }()

    let workManager = WorkManager()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        if let options = launchOptions {
            if let locationOptions  = options[UIApplicationLaunchOptionsLocationKey] as? NSNumber {

                //spin up a location delegate and point the location Manager to it.
                //TODO: move the location delegate to its own class
                let locationDelegate = TableViewController()
                locationManager.delegate = locationDelegate
                locationManager.startUpdatingLocation()
            }
        }

        //register some defaults
        let defaults: [NSObject: AnyObject] = [
            SettingsKey.hoursInWorkWeek.rawValue : NSNumber(int: 40),    // 40 hour work week
            SettingsKey.resetDay.rawValue: NSNumber(int: 0),             // Sunday
            SettingsKey.resetHour.rawValue: NSNumber(int: 4),            // 4 am
            SettingsKey.workRadius.rawValue: NSNumber(int: 200),         // 200m work radius
        ]
        Defaults.standard.registerDefaults(defaults)

        let settings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        
        return true
    }
}
