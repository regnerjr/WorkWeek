import UIKit

class DayTimePicker: NSObject {

    lazy var dateFormatter: NSDateFormatter = {
        return NSDateFormatter()
    }()

    lazy var shortDateFmt: NSDateFormatter = {
        let fmt = NSDateFormatter()
        fmt.timeStyle = NSDateFormatterStyle.ShortStyle
        fmt.dateStyle = NSDateFormatterStyle.ShortStyle
        return fmt
    }()

    var calendar = NSCalendar.currentCalendar()
    //TODO: Look at this awesome Hack?
    weak var dateLabel: UILabel? = nil
}

extension NSCalendar {
    var numberOfWeekdays: Int {
        return self.maximumRangeOfUnit(.Weekday).length
    }
    var numberOfHoursInDay: Int {
        return self.maximumRangeOfUnit(NSCalendarUnit.Hour).length
    }
}

extension DayTimePicker: UIPickerViewDataSource {

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2 //Weekday, Hour
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return calendar.numberOfWeekdays
        case 1: return calendar.numberOfHoursInDay
        default:
            print("Something is wrong")
            return 0
        }
    }
}

extension DayTimePicker: UIPickerViewDelegate {

    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {

        switch component {
        case 0: return makeADayView(row, withLabel: UILabel(frame: CGRectZero))
        case 1: return makeAnHourView(row, withLabel: UILabel(frame: CGRectZero))
        default:
            print("Something is wrong! asked for picker views for component: \(component)")
            return view ?? UIView() //return the same view?
        }
    }

    func makeADayView(row: Int, withLabel label: UILabel) -> UIView {
        let days = dateFormatter.standaloneWeekdaySymbols
        if row < days.count {
            label.text = days[row]
        }
        label.textAlignment = NSTextAlignment.Center
        return label
    }

    func makeAnHourView(row: Int, withLabel label: UILabel) -> UIView {
        if row < calendar.numberOfHoursInDay {
            dateFormatter.timeStyle = .ShortStyle
            let comp = NSDateComponents()
            comp.hour = row
            label.text = dateFormatter.stringFromDate(calendar.dateFromComponents(comp)!)
        }
        label.textAlignment = NSTextAlignment.Center
        return label
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("pickerview selecting New row")
        if let dateLabel = dateLabel {
            let day = pickerView.selectedRowInComponent(0)
            let hour = pickerView.selectedRowInComponent(1)
            let resetDate = getDateForReset(day, hour: hour, minute: 0)
            dateLabel.text = shortDateFmt.stringFromDate(resetDate)
        }
    }


}