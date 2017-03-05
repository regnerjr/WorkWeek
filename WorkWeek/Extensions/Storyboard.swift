import UIKit

public enum Storyboard: String {
    case Main
    case Onboarding
}

extension UIStoryboard {
    static func load(_ storyboard: Storyboard) -> UIStoryboard {
        return self.init(name: storyboard.rawValue, bundle: nil)
    }
}
