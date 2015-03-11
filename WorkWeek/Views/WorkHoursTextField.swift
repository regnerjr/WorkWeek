import UIKit

class WorkHoursTextField: UITextField {

    var workHours : Int {
        get{ return Int(Formatter.workHours.numberFromString(text)!) }
        set{ text = Formatter.workHours.stringFromInt(newValue)   }
    }
    
}
