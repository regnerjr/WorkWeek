import UIKit
import CoreLocation

@UIApplicationMain
public class AppDelegate: UIResponder, UIApplicationDelegate {
    public var window: UIWindow?

    // MARK: - Properties
    lazy var locationManager: CLLocationManager = self.configureLocationManager()
    let workManager = WorkManager()
    var timer: NSTimer = NSTimer()

    // MARK: - Application Lifecycle
    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Alert | .Badge | .Sound, categories: nil))
        NSLog("Registerd for all Notificaiton Types")

        if let options = launchOptions {
            if let locationOptions  = options[UIApplicationLaunchOptionsLocationKey] as? NSNumber {

                //spin up a location delegate and point the location Manager to it.
                //TODO: move the location delegate to its own class
                let locationDelegate = TableViewController()
                locationManager.delegate = locationDelegate
                locationManager.startUpdatingLocation()
            } else if let localNotification = options[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
                NSLog("Got awoked because of a local notification %@", localNotification)
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

        setupATimerToClearTheWeeklyResults()

        return true
    }

    public func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        //show an alertview if teh work week ends and we are in the foreground
        NSLog("Work Week Ended and we were in the foreground")
        let alert = UIAlertView(title: "Work Week is Over!", message: "Go Home", delegate: nil, cancelButtonTitle: nil)
    }


    // MARK: - Helper Functions

    func configureLocationManager() -> CLLocationManager{
        var manager = CLLocationManager()
        let auth = CLLocationManager.authorizationStatus()
        if auth != CLAuthorizationStatus.AuthorizedAlways {
            manager.requestAlwaysAuthorization()
        }
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 200
        manager.pausesLocationUpdatesAutomatically = true
        return manager
    }

    public func setupATimerToClearTheWeeklyResults(){
        timer.invalidate() //invalidate the old Timer
        let week: NSTimeInterval = 7.0 * 24 * 60 * 60 // 7 days, 24 hours per day, 60 minutes, 60 seconds
        //get date from the settings
        if let date = getDateForReset(Defaults.standard.integerForKey(SettingsKey.resetDay),
                                      Defaults.standard.integerForKey(SettingsKey.resetHour),
                                      0) {

            timer = NSTimer(fireDate: date, interval: week, target: workManager, selector: "clearEvents", userInfo: nil, repeats: true)
            NSLog("Set up timer to clear weekly results %@: %@, ", timer, timer.fireDate)

            NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
        } else {
            NSLog("Could not get a reset day for %@, %@",
                Defaults.standard.integerForKey(SettingsKey.resetDay),
                Defaults.standard.integerForKey(SettingsKey.resetHour))
        }
    }
}

public func getDateForReset(day: Int, hour: Int, minute: Int) -> NSDate? {
    // Get the Calendar in use
    let cal = NSCalendar.currentCalendar()
    // Get the current day, Hour, Minute
    let todaysComps = cal.components(NSCalendarUnit.CalendarUnitWeekday |
                                     NSCalendarUnit.CalendarUnitHour |
                                     NSCalendarUnit.CalendarUnitMinute
                                     , fromDate: NSDate())

    // Get the relative components,
    // This is where the real magic happens, How much time between now  and our reset time
    // in days hours minutes
    let resetComps = NSDateComponents()
    resetComps.day    = day - todaysComps.day
    resetComps.hour   = hour - todaysComps.hour
    resetComps.minute = minute - todaysComps.minute

    // Taking the above differences, add them to now
    let date = cal.dateByAddingComponents(resetComps, toDate: NSDate(),
        options: NSCalendarOptions.MatchNextTime)

    return date
}