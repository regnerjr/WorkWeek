import UIKit
import CoreLocation

class OBLocationViewController: UIViewController {

    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var grantAccessButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    var locationAccess: Bool {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways: return true
        case _: return false
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        if !CLLocationManager.locationServicesEnabled() {
            let alert = locationServicesAreNotEnabledOnThisPhoneAlert()
            self.present(alert, animated: true, completion: nil)
        }

    }

    @IBAction func grantAccess(_ sender: UIButton) {
        performSegue(withIdentifier: "OnboardingMapShow", sender: nil)
    }

    @IBAction func cancel(_ sender: UIButton) {
        let alert = createLocationNotInUseWarningPopup()
        self.present(alert, animated: true, completion: nil)
    }

    func locationServicesAreNotEnabledOnThisPhoneAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Error",
                                      message: "Location Services Need to Be " +
                                               "Enabled\nYou can enable access " +
                                               "in\nSettings->Privacy->Location Services",
                                      preferredStyle: UIAlertControllerStyle.actionSheet)
        let goToSettings = UIAlertAction(title: "Settings",
                                         style: UIAlertActionStyle.default, handler: { _ in
            UIApplication.shared.openSettings()
        })
        alert.addAction(goToSettings)
        return alert
    }

    func createLocationNotInUseWarningPopup() -> UIAlertController {
        let alert = UIAlertController(title: "Sorry",
                                      message: "Work Week will not work without access " +
                                               "to your phone's location.",
                                      preferredStyle: UIAlertControllerStyle.alert)
        let OK = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(OK)
        return alert
    }

}
