import UIKit

extension UIApplication {
    func openSettings() {
        openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }

    var del: AppDelegate {
        return self.delegate as! AppDelegate // swiftlint:disable:this force_cast
    }
}
