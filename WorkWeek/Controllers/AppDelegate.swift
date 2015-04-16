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

        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Alert | .Badge | .Sound, categories: nil))
        registerDefaults()

        if let options = launchOptions {
            if let locationOptions  = options[UIApplicationLaunchOptionsLocationKey] as? NSNumber {

                //spin up a location delegate and point the location Manager to it.
                //TODO: move the location delegate to its own class
                let locationDelegate = TableViewController()
                locationManager.delegate = locationDelegate
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
        if let resetDate = Defaults.standard.objectForKey(SettingsKey.clearDate.rawValue) as! NSDate? {
            NSLog("AppDelegate: Got reset Date  - %@", resetDate)
            let now = NSDate()
            let comparison = resetDate.compare(now)
            NSLog("AppDelegate: Comparing Reset Date to now - %d", comparison.rawValue)
            switch comparison {
            case NSComparisonResult.OrderedSame:
                println("Same! nice work. lets clear it anyway")
                workManager.clearEvents()
            case NSComparisonResult.OrderedAscending:
                println("Week has lapsed, Clearing Data")
                workManager.clearEvents()
            case NSComparisonResult.OrderedDescending:
                //time has not yet elapsed do nothing
                println("Week has not yet finished, DO NOT Clear the data")
            }
        }

        // Clear the badge if it is showing
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }

    public func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        NSLog("Application Registered for User Notification Settings %@", notificationSettings)
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


    /// Called when the resetDay or resetHour changes in the Settings screen
    public func updateDefaultResetDate(){
        NSLog("Calling AppDelegate updateDefaultResetDate")
        //get date from the settings
        if let date = getDateForReset(Defaults.standard.integerForKey(SettingsKey.resetDay),
                                      Defaults.standard.integerForKey(SettingsKey.resetHour),
                                      0)
        {
            // Update the Default
            Defaults.standard.setObject(date, forKey: SettingsKey.clearDate.rawValue)

            NSLog("Set End of Week to be %@", date)
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
    resetComps.day    = day - todaysComps.day
    resetComps.hour   = hour - todaysComps.hour
    resetComps.minute = minute - todaysComps.minute

    // Taking the above differences, add them to now
    let date = cal.dateByAddingComponents(resetComps, toDate: NSDate(),
        options: NSCalendarOptions.MatchNextTime)

    return date
}
/// Clears the weekly data if the app is launched after the previous week has expired
///
/// :param: clearDate The Date Configured in the settings screen, Default Sunday 4am
/// :returns: Bool true for success, false for someting unexpected
public func clearLastWeeksData(clearData: NSDate?) -> Bool{
    return false
}