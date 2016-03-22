import UIKit
import CoreLocation

class OBLocationViewController: UIViewController {

    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var grantAccessButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    var locationAccess: Bool {
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways: return true
        case _: return false
        }
    }

    override func viewDidAppear(animated: Bool) {
        if !CLLocationManager.locationServicesEnabled() {
            let alert = locationServicesAreNotEnabledOnThisPhoneAlert()
            self.presentViewController(alert, animated: true, completion: nil)
        }

    }

    @IBAction func grantAccess(sender: UIButton) {
        // Pop up the Location Manager request for Location Access
        let ad = UIApplication.sharedApplication().del
        ad.locationManager = LocationManager()//initialize Location Manager

        performSegueWithIdentifier("OnboardingMapShow", sender: nil)
    }

    @IBAction func cancel(sender: UIButton) {
        let alert = createLocationNotInUseWarningPopup()
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func locationServicesAreNotEnabledOnThisPhoneAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Error",
                                      message: "Location Services Need to Be " +
                                               "Enabled\nYou can enable access " +
                                               "in\nSettings->Privacy->Location Services",
                                      preferredStyle: UIAlertControllerStyle.ActionSheet)
        let goToSettings = UIAlertAction(title: "Settings",
                                         style: UIAlertActionStyle.Default, handler: { action in
            UIApplication.sharedApplication().openSettings()
        })
        alert.addAction(goToSettings)
        return alert
    }

    func createLocationNotInUseWarningPopup() -> UIAlertController {
        let alert = UIAlertController(title: "Sorry",
                                      message: "Work Week will not work without access " +
                                               "to your phone's location.",
                                      preferredStyle: UIAlertControllerStyle.Alert)
        let OK = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(OK)
        return alert
    }

}
