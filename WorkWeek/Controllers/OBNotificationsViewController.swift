import UIKit

class OBNotificationsViewController: UIViewController {

    @IBAction func notifyMe(_ sender: UIButton) {

        let application = UIApplication.shared
        application.registerUserNotificationSettings(
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))

        self.performSegue(withIdentifier: "OBPushNotificationsToSettings", sender: sender)
    }
}
