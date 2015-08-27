import UIKit

class WorkRadiusTextField: UITextField {

    var workRadius : Int {
        get { let num = Formatter.workRadius.numberFromString(text ?? "0")
            return Int(num ?? 0) }
        set { text = Formatter.workRadius.stringFromInt(newValue)      }
    }

}
