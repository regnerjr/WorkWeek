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
        customPicker.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        super.setUp()
    }

    override func tearDown() {
        picker = nil
        super.tearDown()
    }

    func testComponentsForDayOfWeekAndHourOfDay() {
        let comps = picker.numberOfComponents(in: pickerView)
        XCTAssertEqual(comps, 2, "Two Components: 1 for the Day, 1 for the Hour")
    }

    func testRowsInComponent0() {
        let days = picker.pickerView(pickerView, numberOfRowsInComponent: 0)
        XCTAssertEqual(days, 7, "Seven Days in Week") //this test is not good
    }
    func testRowsInComponent1() {
        let hours = picker.pickerView(pickerView, numberOfRowsInComponent: 1)
        XCTAssertEqual(hours, 24, "24 hours in day")
    }
    func testRowsInComponent2() {
        let nothing = picker.pickerView(pickerView, numberOfRowsInComponent: 2)
        XCTAssertEqual(nothing, 0, "Zero rows in undefined component")
    }

    func testDayView() {
        let day = customPicker.pickerView(pickerView, titleForRow: 0, forComponent: 0)
//        let dayView = customPicker.pickerView(pickerView, titForRow: 0,
//                                              forComponent: 0, reusing: nil)
        XCTAssertNotNil(day, "DayView is returned")
        XCTAssertEqual(day, "Sunday",
                       "Sunday is the first component in the day view (for Gregorian Calendar)")
    }

    func testInvalidDayView() {
        let day = customPicker.pickerView(pickerView, titleForRow: 100, forComponent: 0)

        XCTAssertNotNil(day, "Day is returned")
        XCTAssertEqual(day, "")
    }

    func testHourView() {
        let hour = customPicker.pickerView(pickerView, titleForRow: 0, forComponent: 1)

        XCTAssertNotNil(hour, "Hour View is not Nil")
        XCTAssertEqual(hour, "12:00 AM", "First Hour is 12:00 AM")
    }

    func testInvalidHourView() {
        let hour = customPicker.pickerView(pickerView, titleForRow: 100, forComponent: 1)
                XCTAssertNotNil(hour, "Hour View is not Nil")
        XCTAssertEqual(hour, "")
    }

}
