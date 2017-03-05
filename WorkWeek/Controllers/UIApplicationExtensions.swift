import UIKit

extension UIApplication {
    func openSettings() {
        openURL(URL(string: UIApplicationOpenSettingsURLString)!)
    }

    var del: AppDelegate {
        return self.delegate as! AppDelegate // swiftlint:disable:this force_cast
    }
}
