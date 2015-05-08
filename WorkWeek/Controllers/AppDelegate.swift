import UIKit
import CoreLocation

@UIApplicationMain
public class AppDelegate: UIResponder, UIApplicationDelegate {
    public var window: UIWindow?

    // MARK: - Properties
    lazy var locationManager: CLLocationManager = self.configureLocationManager()
    let workManager = WorkManager()

    // MARK: - Application Lifecycle
    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        application.registerUserNotificationSettings(
            UIUserNotificationSettings(forTypes: .Alert | .Badge | .Sound, categories: nil))
        registerDefaults()

        if let options = launchOptions {
            if let locationOptions  = options[UIApplicationLaunchOptionsLocationKey] as? NSNumber {
                resetDataIfNeeded()
                //spin up a location delegate and point the location Manager to it.
                //TODO: move the location delegate to its own class
                locationManager.delegate = TableViewController()
                locationManager.startUpdatingLocation()
            } else if let localNotification = options[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
                NSLog("Launched due to a local notification %@", localNotification)
            }
        }

        return true
    }

    public func applicationWillEnterForeground(application: UIApplication) {
        NSLog("AppDelegate: Entering Foreground")
        //if week has ended clear the work manages data
        resetDataIfNeeded()

        // Clear the badge if it is showing
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }

    func resetDataIfNeeded() {
        if let resetDate = Defaults.standard.objectForKey(SettingsKey.clearDate.rawValue) as! NSDate? {
            let now = NSDate()
            let comparison = resetDate.compare(now)
            NSLog("AppDelegate: Comparing Reset Date to now - %d", comparison.rawValue)
            switch comparison {
            case NSComparisonResult.OrderedSame:
                println("Same! nice work. lets clear it anyway")
                workManager.clearEvents()
                updateDefaultResetDate()
            case NSComparisonResult.OrderedAscending:
                println("Week has lapsed, Clearing Data")
                workManager.clearEvents()
                updateDefaultResetDate()
            case NSComparisonResult.OrderedDescending:
                //time has not yet elapsed do nothing
                println("Week has not yet finished, DO NOT Clear the data")
            }
        }
    }

    public func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        NSLog("Application Registered for User Notification Settings %@", notificationSettings)
    }

    public func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        //show an alertview if teh work week ends and we are in the foreground
        NSLog("Work Week Ended and we were in the foreground")
        let alert = UIAlertController(title: "WorkWeek", message: "Go Home!", preferredStyle: UIAlertControllerStyle.Alert)
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(defaultAction)
        // Who presents this?

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


    /// Called when the resetDay or resetHour changes in the Settings screen
    public func updateDefaultResetDate(){
        //get date from the settings
        if let date = getDateForReset(
                Defaults.standard.integerForKey(SettingsKey.resetDay),
                Defaults.standard.integerForKey(SettingsKey.resetHour),
                0) {
            Defaults.standard.setObject(date, forKey: SettingsKey.clearDate.rawValue)
        } else {
            NSLog("Could not get a reset day for %@, %@",
                Defaults.standard.integerForKey(SettingsKey.resetDay),
                Defaults.standard.integerForKey(SettingsKey.resetHour))
        }
    }

    /// Setup Default values in the NSUserDefaults
    func registerDefaults(){
        //register some defaults
        let defaults: [NSObject: AnyObject] = [
            SettingsKey.hoursInWorkWeek.rawValue : NSNumber(int: 40),    // 40 hour work week
            SettingsKey.resetDay.rawValue: NSNumber(int: 0),             // Sunday
            SettingsKey.resetHour.rawValue: NSNumber(int: 4),            // 4 am
            SettingsKey.workRadius.rawValue: NSNumber(int: 200),         // 200m work radius
            SettingsKey.clearDate.rawValue: getDateForReset(0, 4, 0) ?? NSDate(),
        ]
        Defaults.standard.registerDefaults(defaults)
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
    if (day + 1) < todaysComps.weekday {  //adjust for week wrap.
        resetComps.weekday = (day + 1) - todaysComps.weekday + 7
    } else {
        resetComps.weekday = (day + 1) - todaysComps.weekday
    }
    resetComps.hour   = hour - todaysComps.hour
    resetComps.minute = minute - todaysComps.minute

    // Taking the above differences, add them to now
    let date = cal.dateByAddingComponents(resetComps, toDate: NSDate(),
        options: NSCalendarOptions.MatchNextTime)

    return date
}