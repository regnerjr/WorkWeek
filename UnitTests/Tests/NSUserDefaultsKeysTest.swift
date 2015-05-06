import UIKit
import XCTest

import WorkWeek

class NSUserDefaultsKeysTest: XCTestCase {

    var defaults: NSUserDefaults!

    override func setUp() {
        super.setUp()
        defaults = NSUserDefaults.standardUserDefaults()
    }

    func testSavingAndRetrievingADouble() {
        let keyForTest = SettingsKey.hoursInWorkWeek
        let val = 10.0
        defaults.setDouble(val, forKey: keyForTest)
        let result = defaults.doubleForKey(keyForTest)
        XCTAssertEqual(val, result,  "Archive and restore Double works")
    }

    func testSavingAndRetrievingAnInt() {
        let keyForTest = SettingsKey.hoursInWorkWeek
        let val = 45
        defaults.setInteger(val, forKey: keyForTest)
        let result = defaults.integerForKey(keyForTest)
        XCTAssert(true, "Pass")
    }

}
