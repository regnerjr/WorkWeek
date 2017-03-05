import UIKit

class WorkHoursTextField: UITextField {
    var workHours: Int {
        get { let num = Formatter.workHours.number(from: text ?? "0")
            return Int(num ?? 0) }
        set { text = Formatter.workHours.stringFromInt(newValue)   }
    }

}
