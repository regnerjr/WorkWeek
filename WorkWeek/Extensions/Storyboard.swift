import UIKit

public enum Storyboard: String {
    case Main = "Main"
    case Onboarding = "Onboarding"
}

extension UIStoryboard {
    static func load(storyboard: Storyboard) -> UIStoryboard{
        return self.init(name: storyboard.rawValue, bundle: nil)
    }
}