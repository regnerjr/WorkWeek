import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var workManager = WorkManager() //variable for testing
    lazy var locationManager: LocationManager = {
        return LocationManager()
    }()

    func application(application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        ADHelper.registerDefaults()
        handleLaunchOptions(launchOptions, workManager: workManager)
        loadInterface()
        return true
    }

    func applicationDidBecomeActive(application: UIApplication) {
        workManager.resetDataIfNeeded() //move these to the correct areas
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }

    func application(application: UIApplication,
                     didReceiveLocalNotification notification: UILocalNotification) {
        ADHelper.showGoHomeAlertSheet(onViewController: window?.rootViewController)
    }

    func loadInterface() {
        window?.rootViewController = ADHelper.loadInterface()
    }

    func handleLaunchOptions(options: [NSObject: AnyObject]?, workManager: WorkManager) {
        if let _ = options?[UIApplicationLaunchOptionsLocationKey] as? NSNumber {
            workManager.resetDataIfNeeded()
            locationManager.startUpdatingLocation()
        }
    }
}

class ADHelper {

    static func loadInterface(defaults: NSUserDefaults = Defaults.standard) -> UIViewController? {
        let onboardingHasCompleted = defaults.boolForKey(SettingsKey.OnboardingComplete)
        return getCorrectStoryboard( onboardingHasCompleted )
    }

    static func getCorrectStoryboard(onboardingComplete: Bool ) -> UIViewController? {
        let storyboard = UIStoryboard.load(onboardingComplete ? .Main : .Onboarding)
        return storyboard.instantiateInitialViewController()
    }

    static func showGoHomeAlertSheet(onViewController vc: UIViewController?) {

        guard let vc = vc else { return }
        let alert = UIAlertController(title: "WorkWeek",
                                      message: "Go Home!",
                                      preferredStyle: UIAlertControllerStyle.Alert)
        let defaultAction = UIAlertAction(title: "OK",
                                          style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(defaultAction)
        vc.presentViewController(alert, animated: true, completion: nil)
    }

    static func registerDefaults(userDefaults: NSUserDefaults = Defaults.standard) {
        let defaultResetDate = getDateForReset(0, hour: 4, minute: 0)
        print("Registering Reset Date: \(defaultResetDate)")
        let defaults: [SettingsKey: AnyObject] = [
            SettingsKey.OnboardingComplete : false, //default settings screen is not shown
            SettingsKey.HoursInWorkWeek : 40,    // 40 hour work week
            SettingsKey.ResetDay: 0,             // Sunday
            SettingsKey.ResetHour: 4,            // 4 am
            SettingsKey.WorkRadius: 200,         // 200m work radius
            SettingsKey.ClearDate: defaultResetDate
        ]
        userDefaults.registerDefaults(defaults)
    }

}
