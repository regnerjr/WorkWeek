import UIKit

extension UIApplication {
    func openSettings(){
        openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }
}