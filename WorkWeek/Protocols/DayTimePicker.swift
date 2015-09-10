import UIKit

class DayTimePicker: NSObject {
    lazy var dateFormatter: NSDateFormatter = {
        return NSDateFormatter()
    }()
    var calendar = NSCalendar.currentCalendar()
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
        return label
    }

    func makeAnHourView(row: Int, withLabel label: UILabel) -> UIView {
        if row < calendar.numberOfHoursInDay {
            dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
            let comp = NSDateComponents()
            comp.hour = row
            label.text = dateFormatter.stringFromDate(calendar.dateFromComponents(comp)!)
        }
        return label
    }

}