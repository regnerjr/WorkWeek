import Foundation

/** NSNumberFormatterExtensions Extends NSNumberFormatter

*/
extension NSNumberFormatter {

    func stringFromInt(value: Int) -> String {
        return stringFromNumber(value)!
    }

    func stringFromDouble(value: Double) -> String {
        return stringFromNumber(value)!
    }
}