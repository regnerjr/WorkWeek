import UIKit

public class DayTimePicker: NSObject {
    lazy var dateFormatter: NSDateFormatter = {
        return NSDateFormatter()
    }()
    private let calendar: NSCalendar
    public init(calendar: NSCalendar = NSCalendar.currentCalendar()){
        self.calendar = calendar
    }
}

extension DayTimePicker: UIPickerViewDataSource {

    var numberOfWeekdays: Int {
        return calendar.maximumRangeOfUnit(.CalendarUnitWeekday).length
    }
    var numberOfHoursInDay: Int {
        return calendar.maximumRangeOfUnit(.CalendarUnitHour).length
    }

    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2 //Weekday, Hour
    }

    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return numberOfWeekdays
        case 1: return numberOfHoursInDay
        default:
            println("Something is wrong")
            return 0
        }
    }
}

extension DayTimePicker: UIPickerViewDelegate {

    public func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {

        switch component {
        case 0: return makeADayView(row, withLabel: UILabel(frame: CGRectZero))
        case 1: return makeAnHourView(row, withLabel: UILabel(frame: CGRectZero))
        default:
            println("Something is wrong! asked for picker views for component: \(component)")
            return view //return the same view?
        }
    }


    func makeADayView(row: Int, withLabel label: UILabel) -> UIView {
        let days = dateFormatter.standaloneWeekdaySymbols as! [String]
        if row < days.count {
            label.text = days[row]
        }
        return label
    }

    func makeAnHourView(row: Int, withLabel label: UILabel) -> UIView {
        if row < numberOfHoursInDay {
            dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
            let comp = NSDateComponents()
            comp.hour = row
            label.text = dateFormatter.stringFromDate(calendar.dateFromComponents(comp)!)
        }
        return label
    }

}