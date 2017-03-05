import XCTest

@testable import WorkWeek

class NSNumberFormatterTests: XCTestCase {

    func testFormatterDouble() {
        let formatter = WorkWeek.Formatter.double

        // MARK: - From Int
        let converted = formatter.stringFromInt(0)
        XCTAssertEqual(converted, "0.0", "Converted 0 to \"0.0\"")

        let one = formatter.stringFromInt(1)
        XCTAssertEqual(one, "1.0", "converted 1 to 1.0")

        let ninetyNine = formatter.stringFromInt(99)
        XCTAssertEqual(ninetyNine, "99.0", "99 to 99.0")

        let oneHundred = formatter.stringFromInt(100)
        XCTAssertEqual(oneHundred, "00.0", "100 to 00.0")

        // MARK: - From Double
        let small = formatter.stringFromDouble(0.1)
        XCTAssertEqual(small, "0.1", "0.1 to 0.1")

        let notRounded = formatter.stringFromDouble(0.44)
        XCTAssertEqual(notRounded, "0.4", "0.4 to 0.4")

        let roundUp = formatter.stringFromDouble(0.45)
        XCTAssertEqual(roundUp, "0.5", "0.45 to 0.5")

        let superSmall = formatter.stringFromDouble(0.01)
        XCTAssertEqual(superSmall, "0.0", "converted 0.01 to 0.0")

        let big = formatter.stringFromDouble(99.9)
        XCTAssertEqual(big, "99.9", "99 to 99.9")

        let roundOver = formatter.stringFromDouble(99.95)
        XCTAssertEqual(roundOver, "00.0", "99.95 to 00.0")

        let huge = formatter.stringFromDouble(100.1)
        XCTAssertEqual(huge, "00.1", "100.1 to 00.1")
    }

    func testFormatterWorkHours() {
        let formatter = WorkWeek.Formatter.workHours

        // MARK: - From Int
        let zero = formatter.stringFromInt(0)
        XCTAssertEqual(zero, "0", "Converted 0")

        let one = formatter.stringFromInt(1)
        XCTAssertEqual(one, "1", "Converted 1")

        let ninetyNine = formatter.stringFromInt(99)
        XCTAssertEqual(ninetyNine, "99", "Converted 99")

        let oneHundred = formatter.stringFromInt(100)
        XCTAssertEqual(oneHundred, "00", "Converted 00")

        let hugeInt = formatter.stringFromInt(1000000)
        XCTAssertEqual(hugeInt, "00", "Converted 00")

        // MARK: - From Double
        let converted = formatter.stringFromDouble(0.0)
        XCTAssertEqual(converted, "0", "Converted 0.0")

        let smallOne = formatter.stringFromDouble(0.1)
        XCTAssertEqual(smallOne, "0", "Converted 0.1")

        let smallFour = formatter.stringFromDouble(0.4)
        XCTAssertEqual(smallFour, "0", "Converted 0.4")

        let smallFive = formatter.stringFromDouble(0.5)
        XCTAssertEqual(smallFive, "1", "Converted 0.5")

        let smallSix = formatter.stringFromDouble(0.6)
        XCTAssertEqual(smallSix, "1", "Converted 0.6")

        let smallNine = formatter.stringFromDouble(0.9)
        XCTAssertEqual(smallNine, "1", "Converted 0.9")

        let onePointFive = formatter.stringFromDouble(1.5)
        XCTAssertEqual(onePointFive, "2", "Converted 1.5 to 2")

        let bigOne = formatter.stringFromDouble(99.1)
        XCTAssertEqual(bigOne, "99", "Converted 99.1 to 99")

        let bigFour = formatter.stringFromDouble(99.4)
        XCTAssertEqual(bigFour, "99", "Converted 99.4 to 99")

        let bigFive = formatter.stringFromDouble(99.5)
        XCTAssertEqual(bigFive, "00", "Converted 99.5 to 00")

        let bigSix = formatter.stringFromDouble(99.6)
        XCTAssertEqual(bigSix, "00", "Converted 99.6 to 00")

        let bigNine = formatter.stringFromDouble(99.9)
        XCTAssertEqual(bigNine, "00", "Converted 99.9 to 00")

        let hugeDouble = formatter.stringFromDouble(1000000.4)
        XCTAssertEqual(hugeDouble, "00", "Converted 00")

        let hugeDoubleRound = formatter.stringFromDouble(1000000.6)
        XCTAssertEqual(hugeDoubleRound, "01", "Converted Huge double and rounded")
    }

    func testFormatterWorkRadius() {

        let formatter = WorkWeek.Formatter.workRadius

        // MARK: - Int
        let zero = formatter.stringFromInt(0)
        XCTAssertEqual(zero, "00", "convert 0 to 2 digits 00")
        let one = formatter.stringFromInt(1)
        XCTAssertEqual(one, "01", "convert 1 to 2 digits 01")
        let nines = formatter.stringFromInt(999)
        XCTAssertEqual(nines, "999", "convert 999 to 999")
        let oneThousand = formatter.stringFromInt(1000)
        XCTAssertEqual(oneThousand, "000",
                       "1000 rolls over since formatter is only allowed 3 digits")

        // MARK: - Double
        let small1 = formatter.stringFromDouble(0.1)
        XCTAssertEqual(small1, "01", "Round small numbers up, and adds 2 digits")
        let fifty = formatter.stringFromDouble(50.0)
        XCTAssertEqual(fifty, "50", "drops off double")

        let fiftyPointOne = formatter.stringFromDouble(50.1)
        XCTAssertEqual(fiftyPointOne, "51", "round up 50.1 to 51")
        let ninetyNinePointFive = formatter.stringFromDouble(99.5)
        XCTAssertEqual(ninetyNinePointFive, "100", "round up 99.5 to  100")
        let nineNineEightOne = formatter.stringFromDouble(998.1)
        XCTAssertEqual(nineNineEightOne, "999", "Rounds up 998.1 to 999")
        let nineNineNineOne = formatter.stringFromDouble(999.1)
        XCTAssertEqual(nineNineNineOne, "000", "Round up with overflow 999.1 -> 000")

        let bigOverflow = formatter.stringFromDouble(10000.5)
        XCTAssertEqual(bigOverflow, "001", "Round up with overflow 100000.5 -> 001")
    }

}
