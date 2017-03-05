import Foundation

/**
    Extensions for NSNumberFormatter, to make more code typesafe ish

    I know the docs say that NSNumberFormatter.stringFromNumber() returns
    an optional. Not sure how to cause this behavior. Guess I am OK with force unwrapping this here.
*/
public extension NumberFormatter {

    /// Takes an Int and passes it along to stringFromNumber()
    func stringFromInt(_ value: Int) -> String {
        return string(from: NSNumber(value: value))!
    }

    /// Takes an Double and passes it along to stringFromNumber()
    func stringFromDouble(_ value: Double) -> String {
        return string(from: NSNumber(value: value))!
    }

}
