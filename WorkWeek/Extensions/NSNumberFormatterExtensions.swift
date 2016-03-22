import Foundation

/**
    Extensions for NSNumberFormatter, to make more code typesafe ish

    I know the docs say that NSNumberFormatter.stringFromNumber() returns
    an optional. Not sure how to cause this behavior. Guess I am OK with force unwrapping this here.
*/
public extension NSNumberFormatter {

    /// Takes an Int and passes it along to stringFromNumber()
    func stringFromInt(value: Int) -> String {
        return stringFromNumber(value)!
    }

    /// Takes an Double and passes it along to stringFromNumber()
    func stringFromDouble(value: Double) -> String {
        return stringFromNumber(value)!
    }

}
