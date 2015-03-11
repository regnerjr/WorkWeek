import UIKit

class WorkRadiusTextField: UITextField {

    var workRadius : Int {
        get { return Int(Formatter.workRadius.numberFromString(text)!) }
        set { text = Formatter.workRadius.stringFromInt(newValue)      }
    }

}
