import XCTest

@testable import WorkWeek

class MyDefaults: UserDefaults {
    var getDoubleKey: String!
    var setDoubleKey: String!

    var getIntKey: String!
    var setIntKey: String!

    var getObjectKey: String!
    var setObjectKey: String!

    override func double(forKey defaultName: String) -> Double {
        getDoubleKey = defaultName
        return super.double(forKey: defaultName)
    }
    override func set(_ value: Double, forKey defaultName: String) {
        setDoubleKey = defaultName
        super.set(value, forKey: defaultName)
    }
    override func set(_ value: Int, forKey defaultName: String) {
        setIntKey  = defaultName
        super.set(value, forKey: defaultName)
    }
    override func integer(forKey defaultName: String) -> Int {
        getIntKey = defaultName
        return super.integer(forKey: defaultName)
    }
    override func set(_ value: Any?, forKey defaultName: String) {
        setObjectKey = defaultName
        super.set(value, forKey: defaultName)
    }
    override func object(forKey defaultName: String) -> Any? {
        getObjectKey = defaultName
        return super.object(forKey: defaultName)
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
        XCTAssert(defaults.setDoubleKey == keyForTest.rawValue,
                  "Correct Key is set, in user Defaults")
        let result = defaults.doubleForKey(keyForTest)
        XCTAssert(defaults.getDoubleKey == keyForTest.rawValue,
                  "Correct Key is retrieved, in user Defaults")
        XCTAssertEqual(val, result, "Archive and restore Double works")
    }

    func testSavingAndRetrievingAnInt() {
        let keyForTest = SettingsKey.HoursInWorkWeek
        let val = 45
        defaults.setInteger(val, forKey: keyForTest)
        XCTAssert(defaults.setIntKey == keyForTest.rawValue, "Correct Key is set for Ints")
        let result = defaults.integerForKey(keyForTest)
        XCTAssert(defaults.getIntKey == keyForTest.rawValue, "Correct Key is used for getting Ints")
        XCTAssertEqual(val, result, "Archive and restore Int works")
    }

    func testSavingAndRetrievingADate() {
        let keyForTest = SettingsKey.ClearDate
        let val = Date()
        defaults.set(val, forKey: keyForTest)
        XCTAssert(defaults.setObjectKey == keyForTest.rawValue, "Correct Key is set for Objects")
        let result = defaults.objectForKey(keyForTest) as? Date?
        XCTAssertEqual(defaults.setObjectKey, keyForTest.rawValue,
                       "Correct Key is used for getting object")
        XCTAssert(val.timeIntervalSinceReferenceDate == result!!.timeIntervalSinceReferenceDate,
                  "Archived Date is the same as restored date")
    }

    func testUpdateDefaultResetDate() {
        updateDefaultResetDate(defaults)
        XCTAssertEqual(defaults.setObjectKey, SettingsKey.ClearDate.rawValue,
                       "Sets a new clear date")
    }

}
