import UIKit
import XCTest

import WorkWeek

class NSNumberFormatterTests: XCTestCase {

    func testStringFromInt() {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle

        let converted = formatter.stringFromInt(0)
        XCTAssertEqual(converted, "0", "Converted 0 to \"0\"")

        let maxInt = formatter.stringFromInt(Int.max)
        XCTAssertEqual(maxInt, "9,223,372,036,854,775,807" , "Converted MaxInt to a number")

        let minInt = formatter.stringFromInt(Int.min)
        XCTAssertEqual(minInt, "-9,223,372,036,854,775,808", "Converted Min Int to a number")
    }

    func testStringFromDouble() {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle

        let converted = formatter.stringFromDouble(0.0)
        XCTAssertEqual(converted, "0", "Converted 0.0")

        let onePointFive = formatter.stringFromDouble(1.5)
        XCTAssertEqual(onePointFive, "1.5", "Converted 1.5")

        let infinity = formatter.stringFromDouble(Double.infinity)
        XCTAssertEqual(infinity, "+∞", "Converted Plus Infinity")

        let nan = formatter.stringFromDouble(Double.NaN)
        XCTAssertEqual(nan, "NaN", "Converted Double.NaN")
    }

}