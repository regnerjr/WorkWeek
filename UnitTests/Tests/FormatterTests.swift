import UIKit
import XCTest

import WorkWeek

class FormatterTests: XCTestCase {

    func testDoubleFormatter() {
        let formatZero = Formatter.double.stringFromDouble(0)
        XCTAssertEqual(formatZero, "0.0", "Formatted Zero as a double")

        let format10 = Formatter.double.stringFromDouble(10)
        XCTAssertEqual(format10, "9.9", "Formats 10 as 9.9, the max value")
    }

}
