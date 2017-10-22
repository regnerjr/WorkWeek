import UIKit

public enum Storyboard: String {
    case main = "Main"
    case onboarding = "Onboarding"
}

extension UIStoryboard {
    static func load(_ storyboard: Storyboard) -> UIStoryboard {
        return self.init(name: storyboard.rawValue, bundle: nil)
    }
}
