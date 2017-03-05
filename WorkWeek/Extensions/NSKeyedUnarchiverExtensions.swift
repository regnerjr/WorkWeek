import Foundation

extension NSKeyedUnarchiver {
    static func unarchiveMutableArrayWithFile(_ path: String?) -> NSMutableArray? {
        if let path = path {
            return NSKeyedUnarchiver.unarchiveObject(withFile: path) as? NSMutableArray
        } else {
            return nil
        }

    }
}
