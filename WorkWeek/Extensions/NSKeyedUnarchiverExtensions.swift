import Foundation

extension NSKeyedUnarchiver {
    static func unarchiveMutableArrayWithFile(path: String?) -> NSMutableArray? {
        print(path)
        if let path = path {
            return NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? NSMutableArray
        } else {
            return nil
        }

    }
}
