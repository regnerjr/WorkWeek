import UIKit

class LunchTimeTextField: UITextField {

    var lunchTime: Double {
        get{ return Double(Formatter.double.numberFromString(text)!) }
        set{ text = Formatter.double.stringFromDouble(newValue)      }
    }

}
