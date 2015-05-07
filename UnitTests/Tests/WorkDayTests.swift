import UIKit
import XCTest

import WorkWeek

class WorkDayTests: XCTestCase {

    func testDecimalHoursEightPoint0() {
        let hours = WorkDay(weekDay: "Mon", hoursWorked: 8, minutesWorked: 1, arrivalTime: "8:00 AM", departureTime: "3:00 PM")
        let decimalHours = hours.decimalHoursWorked
        XCTAssertEqual(decimalHours, "8.0", "8 hours 1 minutes is 8.0 Hours")
    }
    func testDecimalHoursStillEightPoint0() {
        let hours = WorkDay(weekDay: "Mon", hoursWorked: 8, minutesWorked: 5, arrivalTime: "8:00 AM", departureTime: "3:00 PM")
        let decimalHours = hours.decimalHoursWorked
        XCTAssertEqual(decimalHours, "8.0", "8 hours 5 minutes is 8.0 Hours")
    }
    func testDecimalHoursEightPoint1() {
        let hours = WorkDay(weekDay: "Mon", hoursWorked: 8, minutesWorked: 6, arrivalTime: "8:00 AM", departureTime: "3:00 PM")
        let decimalHours = hours.decimalHoursWorked
        XCTAssertEqual(decimalHours, "8.1", "8 hours 6 minutes is 8.1 Hours")
    }
    func testDecimalHoursStillEightPoint1() {
        let hours = WorkDay(weekDay: "Mon", hoursWorked: 8, minutesWorked: 11, arrivalTime: "8:00 AM", departureTime: "3:00 PM")
        let decimalHours = hours.decimalHoursWorked
        XCTAssertEqual(decimalHours, "8.1", "8 hours 11 minutes is 8.1 Hours")
    }
    func testDecimalHoursEightPoint2() {
        let hours = WorkDay(weekDay: "Mon", hoursWorked: 8, minutesWorked: 12, arrivalTime: "8:00 AM", departureTime: "3:00 PM")
        let decimalHours = hours.decimalHoursWorked
        XCTAssertEqual(decimalHours, "8.2", "8 hours 12 minutes is 8.2 Hours")
    }
    func testDecimalHoursStillEightPoint2() {
        let hours = WorkDay(weekDay: "Mon", hoursWorked: 8, minutesWorked: 17, arrivalTime: "8:00 AM", departureTime: "3:00 PM")
        let decimalHours = hours.decimalHoursWorked
        XCTAssertEqual(decimalHours, "8.2", "8 hours 17 minutes is 8.2 Hours")
    }
    func testDecimalHours54PastTheHour() {
        let hours = WorkDay(weekDay: "Mon", hoursWorked: 8, minutesWorked: 54, arrivalTime: "8:00 AM", departureTime: "3:00 PM")
        let decimalHours = hours.decimalHoursWorked
        XCTAssertEqual(decimalHours, "8.9", "8 hours 54 minutes is 8.9 Hours")
    }
    func testDecimalHours59PastTheHour() {
        let hours = WorkDay(weekDay: "Mon", hoursWorked: 8, minutesWorked: 59, arrivalTime: "8:00 AM", departureTime: "3:00 PM")
        let decimalHours = hours.decimalHoursWorked
        XCTAssertEqual(decimalHours, "8.9", "8 hours 59 minutes is 8.9 Hours")
    }
}
