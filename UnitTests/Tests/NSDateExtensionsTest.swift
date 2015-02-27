import Foundation
import XCTest

class NSDateExtensionsTest: XCTestCase {

    func testDateGivesCorrectDayOfWeek(){
        //interval since reference date gives Jan 1, 2001 a Monday 
        //this result can be found by running `$ cal Jan 2001` in your shell
        let date = NSDate(timeIntervalSinceReferenceDate: 0)

        NSTimeZone.setDefaultTimeZone(NSTimeZone(forSecondsFromGMT: 0))
        //set time zone to gmt else the day of the week could be interpreted
        //incorrectly. When testing this I originally had some testing issues.
        // asking for the NSDate(timeIntervalSinceReferenceDate: 0) gives Jan 1, 2001 00:00:00 GMT
        // When printing this out using a formatter as dayOfWeek does, I live in 
        // United States Central time, which is some hours less than gmt, thus 
        // the day of the week was 1 prior to what I was expecting.
        XCTAssertEqual(date.dayOfWeek, "Mon",
            "Day of week is calculated Correctly. Jan 1, 2001 is a Monday")
    }
}
