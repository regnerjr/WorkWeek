import UIKit

class Stepper: UIStepper {

    var workHours : Int {
        get { return Int(value) }
        set { value = Double(newValue) }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        minimumValue = 1
        maximumValue = 100
        stepValue = 1
    }
}