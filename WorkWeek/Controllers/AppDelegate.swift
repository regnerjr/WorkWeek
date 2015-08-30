import UIKit

@UIApplicationMain
public class AppDelegate: UIResponder, UIApplicationDelegate {

    public var window: UIWindow?
    public var workManager = WorkManager() //variable for testing
    lazy var locationManager: LocationManager = {
        return LocationManager()
    }()


    // MARK: - Application Lifecycle
    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        registerDefaults()
        handleLaunchOptions(launchOptions)
        loadInterface()
        return true
    }

    public func applicationWillEnterForeground(application: UIApplication) {
        workManager.resetDataIfNeeded()
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }

    public func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        print("Work Week Ended and we were in the foreground")
        let alert = UIAlertController(title: "WorkWeek", message: "Go Home!", preferredStyle: UIAlertControllerStyle.Alert)
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(defaultAction)

        // TODO: Ask about this at Coder Night?
        //Where do I display this alert?
        //Fire off a notification and let each class handle it independeltly?
        // just push a WorkWeekEnded VC onto window.rootviewController ... ? ... ?

    }

    func loadInterface(){
        let onboardingHasCompleted = Defaults.standard.boolForKey(SettingsKey.onboardingComplete)
        window?.rootViewController = getCorrectStoryboard( onboardingHasCompleted )
    }

    func getCorrectStoryboard(onboardingComplete: Bool ) -> UIViewController? {
        let storyboard = UIStoryboard.load(onboardingComplete ? .Main : .Onboarding)
        return storyboard.instantiateInitialViewController()
    }

    func handleLaunchOptions(options: [NSObject: AnyObject]?){
        if let _ = options?[UIApplicationLaunchOptionsLocationKey] as? NSNumber {
            workManager.resetDataIfNeeded()
            locationManager.manager.startUpdatingLocation()
        } else if let localNotification = options?[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
            NSLog("Launched due to a local notification %@", localNotification)
        }
    }

    func registerDefaults(standardDefaults: NSUserDefaults = Defaults.standard){
        let defaults: [String: AnyObject] = [
            SettingsKey.onboardingComplete.rawValue : false,             //default settings screen is not shown
            SettingsKey.hoursInWorkWeek.rawValue : NSNumber(int: 40),    // 40 hour work week
            SettingsKey.resetDay.rawValue: NSNumber(int: 0),             // Sunday
            SettingsKey.resetHour.rawValue: NSNumber(int: 4),            // 4 am
            SettingsKey.workRadius.rawValue: NSNumber(int: 200),         // 200m work radius
            SettingsKey.clearDate.rawValue: getDateForReset(0, hour: 4, minute: 0) ?? NSDate(),
        ]
        standardDefaults.registerDefaults(defaults)
    }
}
