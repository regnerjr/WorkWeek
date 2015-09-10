import UIKit
import XCTest

import WorkWeek

class AppDelegateTests: XCTestCase {

    var appDelegate: AppDelegate!
    var app: UIApplication!

    override func setUp() {
        super.setUp()
        app = UIApplication.sharedApplication()
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    override func tearDown() {
        app = nil
        appDelegate = nil
        super.tearDown()
    }

    func testUpdateDefaultResetDate(){
        //set new values in the NSUserDefaults, thn see what new date gets set in the NSUserDefaults
        //put in monday at 9 -> 2, 9
        Defaults.standard.setInteger(2, forKey: SettingsKey.resetDay)
        Defaults.standard.setInteger(9, forKey: SettingsKey.resetHour)

        updateDefaultResetDate()
        let savedDate = Defaults.standard.objectForKey(SettingsKey.clearDate.rawValue) as! NSDate

        //how to test that this is the monday at 9 time?
        //look at the components

        let resetComps = NSCalendar.currentCalendar().components(
            [NSCalendarUnit.Weekday, NSCalendarUnit.Hour, NSCalendarUnit.Minute],
            fromDate: savedDate)
        print("\(savedDate)")
        XCTAssertEqual(resetComps.weekday, 3, "Reset day set to sunday")
        XCTAssertEqual(resetComps.hour, 9, "Reset hour is 4 am ")
        let comparison = NSDate().compare(savedDate)
        XCTAssertEqual(comparison, NSComparisonResult.OrderedAscending, "Reset Date is in the future")
        //but it is less than 1 week in the future
        let oneWeekComparison = NSDate(timeIntervalSinceNow: 7 * 24 * 60 * 60).compare(savedDate) //one week 7days, 24hours,60minutes, 60 seconds
        XCTAssertEqual(oneWeekComparison.rawValue, NSComparisonResult.OrderedDescending.rawValue, "Reset Date is less than one week in the future")


    }

}
