import UIKit
import XCTest

import WorkWeek

class FormatterTests: XCTestCase {

    func testDoubleFormatter() {
        let formatZero = Formatter.double.stringFromDouble(0)
        XCTAssertEqual(formatZero, "0.0", "Formatted Zero as a double")

        let format10 = Formatter.double.stringFromDouble(10)
        XCTAssertEqual(format10, "0.0", "Formats 10 as 0.0")
        
        let format10_1 = Formatter.double.stringFromDouble(10.1)
        XCTAssertEqual( format10_1, "0.1", "Formats 10.1 as 0.1")
    }

}
