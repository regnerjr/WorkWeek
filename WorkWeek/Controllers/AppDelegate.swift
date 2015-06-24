import UIKit
//import CoreLocation



@UIApplicationMain
public class AppDelegate: UIResponder, UIApplicationDelegate {
    public var window: UIWindow?

    // MARK: - Properties
    let workManager = WorkManager()
    //don't stand up Location Manager if the onboarding screen has not been shown
    lazy var locationManager: LocationManager? = {
        if Defaults.standard.boolForKey(SettingsKey.onboardingShown.rawValue) == false {
            return nil
        }
        return LocationManager()
    }()

    public enum StoryBoard: String {
        case Main = "Main"
        case Onboarding = "Onboarding"
    }

    // MARK: - Application Lifecycle
    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        registerDefaults()

        if let options = launchOptions {
            if let locationOptions  = options[UIApplicationLaunchOptionsLocationKey] as? NSNumber {
                workManager.resetDataIfNeeded()
                locationManager?.manager.startUpdatingLocation()
            } else if let localNotification = options[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
                NSLog("Launched due to a local notification %@", localNotification)
            }
        }

        if( !Defaults.standard.boolForKey(SettingsKey.onboardingShown.rawValue)) {
            loadInterface(StoryBoard.Onboarding)
        } else {
            loadInterface(StoryBoard.Main)
        }

        return true
    }

    public func loadInterface(storyboard: StoryBoard){
        let storyboard = UIStoryboard(name: storyboard.rawValue, bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! UIViewController
        self.window?.rootViewController = controller
    }

    public func applicationWillEnterForeground(application: UIApplication) {
        NSLog("AppDelegate: Entering Foreground")
        //if week has ended clear the work managers data
        workManager.resetDataIfNeeded()

        // Clear the badge if it is showing
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }

    public func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        //show an alertview if the work week ends and we are in the foreground
        NSLog("Work Week Ended and we were in the foreground")
        let alert = UIAlertController(title: "WorkWeek", message: "Go Home!", preferredStyle: UIAlertControllerStyle.Alert)
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(defaultAction)
        // TODO: Finish This

    }

    /// Setup Default values in the NSUserDefaults
    func registerDefaults(standardDefaults: NSUserDefaults = Defaults.standard){
        //register some defaults
        let defaults: [NSObject: AnyObject] = [
            SettingsKey.onboardingShown.rawValue : false,                //default settings screen is not shown
            SettingsKey.hoursInWorkWeek.rawValue : NSNumber(int: 40),    // 40 hour work week
            SettingsKey.resetDay.rawValue: NSNumber(int: 0),             // Sunday
            SettingsKey.resetHour.rawValue: NSNumber(int: 4),            // 4 am
            SettingsKey.workRadius.rawValue: NSNumber(int: 200),         // 200m work radius
            SettingsKey.clearDate.rawValue: getDateForReset(0, 4, 0) ?? NSDate(),
        ]
        standardDefaults.registerDefaults(defaults)
    }
}