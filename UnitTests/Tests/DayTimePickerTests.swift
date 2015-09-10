import XCTest

@testable import WorkWeek

class DayTimePickerTests: XCTestCase {

    var picker: DayTimePicker!
    var pickerView: UIPickerView!
    var customPicker: DayTimePicker!

    override func setUp() {
        picker = DayTimePicker()
        pickerView = UIPickerView(frame: .zero)
        customPicker = DayTimePicker()
        customPicker.calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        super.setUp()
    }
    
    override func tearDown() {
        picker = nil
        super.tearDown()
    }

    func testComponentsForDayOfWeekAndHourOfDay() {
        let comps = picker.numberOfComponentsInPickerView(pickerView)
        XCTAssertEqual(comps, 2, "Two Components: 1 for the Day, 1 for the Hour")
    }

    func testRowsInComponent0(){
        let days = picker.pickerView(pickerView, numberOfRowsInComponent: 0)
        XCTAssertEqual(days, 7, "Seven Days in Week") //this test is not good
    }
    func testRowsInComponent1(){
        let hours = picker.pickerView(pickerView, numberOfRowsInComponent: 1)
        XCTAssertEqual(hours, 24, "24 hours in day")
    }
    func testRowsInComponent2(){
        let nothing = picker.pickerView(pickerView, numberOfRowsInComponent: 2)
        XCTAssertEqual(nothing, 0, "Zero rows in undefined component")
    }

    func testDayView(){
        let dayView = customPicker.pickerView(pickerView, viewForRow: 0, forComponent: 0, reusingView: nil)
        XCTAssertNotNil(dayView, "DayView is returned")
        let daylabel = dayView as! UILabel
        XCTAssertEqual(daylabel.text!, "Sunday", "Sunday is the first component in the day view (for Gregorian Calendar)")
    }

    func testInvalidDayView(){
        let dayView = customPicker.pickerView(pickerView, viewForRow: 100, forComponent: 0, reusingView: nil)
        XCTAssertNotNil(dayView, "DayView is returned")
        let daylabel = dayView as! UILabel
        XCTAssertNotNil(daylabel, "DayLabel is not nil")
        XCTAssertNil(daylabel.text, "Text is not set on invald items")
    }

    func testHourView(){
        let hourView = customPicker.pickerView(pickerView, viewForRow: 0, forComponent: 1, reusingView: nil)
        XCTAssertNotNil(hourView, "Hour View is not Nil")
        let hourLabel = hourView as! UILabel
        XCTAssertEqual(hourLabel.text!, "12:00 AM", "First Hour is 12:00 AM")
    }

    func testInvalidHourView(){
        let hourView = customPicker.pickerView(pickerView, viewForRow: 100, forComponent: 1, reusingView: nil)
        XCTAssertNotNil(hourView, "Hour View is not Nil")
        let hourLabel = hourView as! UILabel
        XCTAssertNotNil(hourLabel, "Hour Label is not nil")
        XCTAssertNil(hourLabel.text, "Text is not set on invald items")
    }

}
