import UIKit

class DayTimePicker: NSObject {

    lazy var dateFormatter: DateFormatter = {
        return DateFormatter()
    }()

    lazy var shortDateFmt: DateFormatter = {
        let fmt = DateFormatter()
        fmt.timeStyle = DateFormatter.Style.short
        fmt.dateStyle = DateFormatter.Style.short
        return fmt
    }()

    var calendar = Calendar.current
    // TODO: Look at this awesome Hack?
    weak var dateLabel: UILabel?
}

extension Calendar {
    var numberOfWeekdays: Int {
        return (self as NSCalendar).maximumRange(of: .weekday).length
    }
    var numberOfHoursInDay: Int {
        return (self as NSCalendar).maximumRange(of: NSCalendar.Unit.hour).length
    }
}

extension DayTimePicker: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2 //Weekday, Hour
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
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

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0: return makeADayView(row)
        case 1: return makeAnHourView(row)
        default:
            print("Something is wrong! asked for picker views for component: \(component)")
            return ""
        }
    }

    func makeADayView(_ row: Int) -> String {
        guard let days = dateFormatter.standaloneWeekdaySymbols, row < days.count else {
            print("🐛 Something is wrong here,\(#function)")
            return ""
        }
        return days[row]
    }

    func makeAnHourView(_ row: Int) -> String {
        guard row < calendar.numberOfHoursInDay else {
            print("🐛 Something is wrong here,\(#function)")
            return ""
        }
        dateFormatter.timeStyle = .short
        var comp = DateComponents()
        comp.hour = row
        return dateFormatter.string(from: calendar.date(from: comp)!)
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("pickerview selecting New row")
        if let dateLabel = dateLabel {
            let day = pickerView.selectedRow(inComponent: 0)
            let hour = pickerView.selectedRow(inComponent: 1)
            let resetDate = getDateForReset(day, hour: hour, minute: 0)
            dateLabel.text = shortDateFmt.string(from: resetDate)
        }
    }

}
