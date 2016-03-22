import UIKit

class Stepper: UIStepper {

    var workHours: Int {
        get { return Int(value) }
        set { value = Double(newValue) }
    }
}
