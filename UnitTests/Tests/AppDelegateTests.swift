import XCTest
import CoreLocation

@testable import WorkWeek

class AppDelegateTests: XCTestCase {

    class StubWorkManager: WorkManager {
        var resetWasCalled = false
        override func resetDataIfNeeded(_ defaults: UserDefaults = Defaults.standard) {
            resetWasCalled = true
        }
    }

    class StubLocationManager: LocationManager {
        var startedUpdating = false
        override func startUpdatingLocation() {
            startedUpdating = true
        }
    }

    let mockLocDel = MockLocationDelegate()

    override func setUp() {
        super.setUp()

        //Clear User Defaults
        let domainName = Bundle.main.bundleIdentifier
        UserDefaults.standard.removePersistentDomain(forName: domainName!)
    }

    func testDataIsResetWhenApplicationEntersForeground() {
        let app = UIApplication.shared
        guard let appDelegate = app.delegate as? AppDelegate else {
            fatalError("Could not get App Delegate")
        }

        let wm = StubWorkManager()
        appDelegate.workManager = wm

        appDelegate.applicationDidBecomeActive(app)
        XCTAssert(wm.resetWasCalled)
    }

    func testApplicationBadgeIsClearedWhenAppEntersForeground() {
        let app = UIApplication.shared
        guard let appDelegate = app.delegate as? AppDelegate else {
            fatalError("Could Not Get App Delegate")
        }

        app.applicationIconBadgeNumber = 40
        XCTAssert(app.applicationIconBadgeNumber > 0)

        appDelegate.applicationDidBecomeActive(app)
        XCTAssert(app.applicationIconBadgeNumber == 0)
    }

    func testDidReceiveLocalNotificationShowsAlert() {
        let app = UIApplication.shared
        guard let appDelegate = app.delegate as? AppDelegate else {
            fatalError("Could not get app Delegate")
        }

        let vc = UIViewController()
        appDelegate.window?.rootViewController = vc //inject that junk
        _ = vc.view //load view
        XCTAssertNil(vc.presentedViewController)

        appDelegate.application(app, didReceive: UILocalNotification())
        XCTAssertNotNil(vc.presentedViewController)
        XCTAssert(type(of: vc.presentedViewController!) == UIAlertController.self)
    }

    func testLoadInterfaceReturnsCorrectStoryboardIfOnboardingIsNOTComplete() {
        let def = UserDefaults(suiteName: "testDefaults")
        def?.setBool(false, forKey: SettingsKey.OnboardingComplete)
        let onboardingVC = ADHelper.loadInterface(def!)
        XCTAssert(onboardingVC is UINavigationController)
        let firstVC = (onboardingVC as? UINavigationController)?.topViewController
        XCTAssert(firstVC?.restorationIdentifier == "OnboardingFirstScreen")

    }

    func testLoadInterfaceReturnsCorrectStoryboardIfOnboardingIsComplete() {
        let def = UserDefaults(suiteName: "testDefaults")
        def?.setBool(true, forKey: SettingsKey.OnboardingComplete)
        let onboardingVC = ADHelper.loadInterface(def!)

        XCTAssert(onboardingVC?.restorationIdentifier == "MainStoryboardInitialVC")
    }

    func testShowGoHomeAlertSheet() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Could not get app Delegate")
        }

        let vc = UIViewController()//Must put VC in window hirearchy in order to present stuff
        appDelegate.window?.rootViewController = vc
        XCTAssertNil(vc.presentedViewController)

        ADHelper.showGoHomeAlertSheet(onViewController: vc)
        XCTAssertNotNil(vc.presentedViewController)
        XCTAssert(type(of: vc.presentedViewController!) == UIAlertController.self)
    }

    func testDoesNotShowGoHomeAlertSheetIfPassedInVCIsNone() {
        let vc = UIViewController()//Must put VC in window hirearchy in order to present stuff
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Could not get app Delegate")
        }
        appDelegate.window?.rootViewController = vc
        XCTAssertNil(vc.presentedViewController)
    }

    func testHandleLaunch_No_Options() {
        let wm = StubWorkManager()
        let lm = StubLocationManager(locationDelegate: mockLocDel)

        let options: [AnyHashable: Any]? = nil
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Could not get app delegate")
        }
        appDelegate.handleLaunchOptions(options, workManager: wm)
        XCTAssert(wm.resetWasCalled == false)
        XCTAssert(lm.startedUpdating == false)
    }

    func testHandleLaunchOptionLocalNotificationOption() {
        let wm = StubWorkManager()
        let lm = StubLocationManager(locationDelegate: mockLocDel)

        let options = [UIApplicationLaunchOptionsKey.location: NSNumber(value: true as Bool)]
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Could not get App Delegate")
        }
        appDelegate.locationManager = lm
        appDelegate.handleLaunchOptions(options, workManager: wm)
        XCTAssert(wm.resetWasCalled)
        XCTAssert(lm.startedUpdating)
    }

    func testRegisteringDefaults() {

        //user defaults are registered at app launch. So verify that everything is normal
        let def = UserDefaults.standard

        ADHelper.registerDefaults(def)
        XCTAssertFalse(def.boolForKey(.OnboardingComplete))
        XCTAssert(def.integerForKey(.HoursInWorkWeek) == 40)
        XCTAssert(def.integerForKey(.ResetDay) == 0)
        XCTAssert(def.integerForKey(.ResetHour) == 4)
        XCTAssert(def.integerForKey(.WorkRadius) == 200)

        guard let resetDate = def.objectForKey(.ClearDate) as? Date else {
            XCTFail("Clear data is not set")
            return
        }

        let cal = Calendar.current
        let comps = (cal as NSCalendar).components([.day, .hour, .minute, .weekday], from: resetDate)
        XCTAssert(comps.weekday == 1)//sunday
        XCTAssert(comps.hour == 4)//4am
        XCTAssert(comps.minute == 0)//4am
    }

}
