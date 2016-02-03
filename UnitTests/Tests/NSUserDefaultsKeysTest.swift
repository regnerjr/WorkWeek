import XCTest

@testable import WorkWeek

class MyDefaults: NSUserDefaults {
    var getDoubleKey: String!
    var setDoubleKey: String!

    var getIntKey: String!
    var setIntKey: String!

    var getObjectKey: String!
    var setObjectKey: String!

    override func doubleForKey(defaultName: String) -> Double {
        getDoubleKey = defaultName
        return super.doubleForKey(defaultName)
    }
    override func setDouble(value: Double, forKey defaultName: String) {
        setDoubleKey = defaultName
        super.setDouble(value, forKey: defaultName)
    }
    override func setInteger(value: Int, forKey defaultName: String) {
        setIntKey  = defaultName
        super.setInteger(value, forKey: defaultName)
    }
    override func integerForKey(defaultName: String) -> Int {
        getIntKey = defaultName
        return super.integerForKey(defaultName)
    }
    override func setObject(value: AnyObject?, forKey defaultName: String) {
        setObjectKey = defaultName
        super.setObject(value, forKey: defaultName)
    }
    override func objectForKey(defaultName: String) -> AnyObject? {
        getObjectKey = defaultName
        return super.objectForKey(defaultName)
    }

}

class NSUserDefaultsKeysTest: XCTestCase {

    var defaults: MyDefaults!

    override func setUp() {
        super.setUp()
        defaults = MyDefaults()
    }
    override func tearDown() {
        defaults = nil
    }

    func testSavingAndRetrievingADouble() {
        let keyForTest = SettingsKey.HoursInWorkWeek
        let val = 10.0
        defaults.setDouble(val, forKey: keyForTest)
        XCTAssert(defaults.setDoubleKey == keyForTest.rawValue, "Correct Key is set, in user Defaults")
        let result = defaults.doubleForKey(keyForTest)
        XCTAssert(defaults.getDoubleKey == keyForTest.rawValue, "Correct Key is retrieved, in user Defaults")
        XCTAssertEqual(val, result,  "Archive and restore Double works")
    }

    func testSavingAndRetrievingAnInt() {
        let keyForTest = SettingsKey.HoursInWorkWeek
        let val = 45
        defaults.setInteger(val, forKey: keyForTest)
        XCTAssert(defaults.setIntKey == keyForTest.rawValue, "Correct Key is set for Ints")
        let result = defaults.integerForKey(keyForTest)
        XCTAssert(defaults.getIntKey == keyForTest.rawValue, "Correct Key is used for getting Ints")
        XCTAssertEqual(val, result,  "Archive and restore Int works")
    }

    func testSavingAndRetrievingADate() {
        let keyForTest = SettingsKey.ClearDate
        let val = NSDate()
        defaults.setObject(val, forKey: keyForTest)
        XCTAssert(defaults.setObjectKey == keyForTest.rawValue, "Correct Key is set for Objects")
        let result = defaults.objectForKey(keyForTest) as! NSDate?
        XCTAssertEqual(defaults.setObjectKey, keyForTest.rawValue, "Correct Key is used for getting object")
        XCTAssert(val.timeIntervalSinceReferenceDate == result!.timeIntervalSinceReferenceDate, "Archived Date is the same as restored date")
    }

    func testUpdateDefaultResetDate(){
        updateDefaultResetDate(defaults)
        XCTAssertEqual(defaults.setObjectKey, SettingsKey.ClearDate.rawValue, "Sets a new clear date")
    }

}
