import Foundation

extension NSKeyedUnarchiver {
    static func unarchiveMutableArrayWithFile(path: String?) -> NSMutableArray?{
        if let path = path {
            return NSKeyedUnarchiver.unarchiveObjectWithFile(path) as! NSMutableArray?
        } else {
            return nil
        }

    }
}
