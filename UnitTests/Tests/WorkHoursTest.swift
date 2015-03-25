import UIKit
import XCTest

import WorkWeek

class WorkHoursTest: XCTestCase {

    func testDecimalHoursWorked(){
        // NOTE: All times will round down, only when 6 minute increments are complete does the system grant you the next 10th of an hour
        let day = WorkDay(weekDay: "blarg", hoursWorked: 0, minutesWorked: 6, arrivalTime: "blarg", departureTime: "blarg")
        XCTAssertEqual(day.decimalHoursWorked, "0.1", "6 minutes worked is equal to 0.1 hours")

        let day1 = WorkDay(weekDay: "blarg", hoursWorked: 1, minutesWorked: 6, arrivalTime: "blarg", departureTime: "blarg")
        XCTAssertEqual(day1.decimalHoursWorked, "1.1", "1hour & 6 minutes worked is equal to 1.1 hours")

        let day2 = WorkDay(weekDay: "blarg", hoursWorked: 2, minutesWorked: 15, arrivalTime: "blarg", departureTime: "blarg")
        XCTAssertEqual(day2.decimalHoursWorked, "2.2", "2 hours 15 should round donwn to 2.2 hours")

        let day3 = WorkDay(weekDay: "blarg", hoursWorked: 10, minutesWorked: 35, arrivalTime: "blarg", departureTime: "blarg")
        XCTAssertEqual(day3.decimalHoursWorked, "10.5", "10 hours 35 should round down to  10.5 hours")
    }

}
