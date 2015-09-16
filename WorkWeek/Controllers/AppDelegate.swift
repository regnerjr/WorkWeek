import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var workManager = WorkManager() //variable for testing
    lazy var locationManager: LocationManager = {
        return LocationManager()
    }()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        ADHelper.registerDefaults()
        handleLaunchOptions(launchOptions, workManager: workManager)
        loadInterface()
        return true
    }

    func applicationWillEnterForeground(application: UIApplication) {
        workManager.resetDataIfNeeded()
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        ADHelper.showGoHomeAlertSheet(onViewController: window?.rootViewController)
    }

    func loadInterface(){
        window?.rootViewController = ADHelper.loadInterface()
    }

    func handleLaunchOptions(options: [NSObject: AnyObject]?, workManager: WorkManager){
        if let _ = options?[UIApplicationLaunchOptionsLocationKey] as? NSNumber {
            workManager.resetDataIfNeeded()
            locationManager.startUpdatingLocation()
        }
    }
}

class ADHelper {

    static func loadInterface(defaults: NSUserDefaults = Defaults.standard) -> UIViewController? {
        let onboardingHasCompleted = defaults.boolForKey(SettingsKey.onboardingComplete)
        return getCorrectStoryboard( onboardingHasCompleted )
    }

    static func getCorrectStoryboard(onboardingComplete: Bool ) -> UIViewController? {
        let storyboard = UIStoryboard.load(onboardingComplete ? .Main : .Onboarding)
        return storyboard.instantiateInitialViewController()
    }

    static func showGoHomeAlertSheet(onViewController vc: UIViewController?){

        guard let vc = vc else { return }
        let alert = UIAlertController(title: "WorkWeek", message: "Go Home!", preferredStyle: UIAlertControllerStyle.Alert)
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(defaultAction)
        vc.presentViewController(alert, animated: true, completion: nil)
    }


    static func registerDefaults(userDefaults: NSUserDefaults = Defaults.standard){
        let defaultResetDate = getDateForReset(0, hour: 4, minute: 0)
        print("Registering Reset Date: \(defaultResetDate)")
        let defaults: [String: AnyObject] = [
            SettingsKey.onboardingComplete.rawValue : false,             //default settings screen is not shown
            SettingsKey.hoursInWorkWeek.rawValue : 40,    // 40 hour work week
            SettingsKey.resetDay.rawValue: 0,             // Sunday
            SettingsKey.resetHour.rawValue: 4,            // 4 am
            SettingsKey.workRadius.rawValue: 200,         // 200m work radius
            SettingsKey.clearDate.rawValue: defaultResetDate
        ]
        userDefaults.registerDefaults(defaults)
    }

}
