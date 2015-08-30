import UIKit

class OBNotificationsViewController: UIViewController {

    @IBAction func notifyMe(sender: UIButton) {

        let application = UIApplication.sharedApplication()
        application.registerUserNotificationSettings(
            UIUserNotificationSettings(forTypes: .Alert | .Badge | .Sound, categories: nil))

        self.performSegueWithIdentifier("OBPushNotificationsToSettings", sender: sender)
    }
}
