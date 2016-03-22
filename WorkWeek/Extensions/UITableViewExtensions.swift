//
//  UITableViewExtensions.swift
//  WorkWeek
//
//  Created by John Regner on 3/22/16.
//  Copyright © 2016 WigglingScholars. All rights reserved.
//

import UIKit

extension UITableView {
    func dequeueReusableHeaderFooterViewWithIdentifier(
            identifier: ReuseIdentifiers) -> UITableViewHeaderFooterView? {
        return self.dequeueReusableHeaderFooterViewWithIdentifier(identifier.rawValue)
    }

    func registerClass(aClass: AnyClass?,
                         forHeaderFooterViewReuseIdentifier identifier: ReuseIdentifiers) {
        return self.registerClass(aClass, forHeaderFooterViewReuseIdentifier: identifier.rawValue)

    }

    func dequeueReusableCellWithIdentifier(identifier: ReuseIdentifiers) -> UITableViewCell? {
        return self.dequeueReusableCellWithIdentifier(identifier.rawValue)
    }
    func dequeueReusableCellWithIdentifier(identifier: ReuseIdentifiers,
                                           forIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return dequeueReusableCellWithIdentifier(identifier.rawValue, forIndexPath: indexPath)
    }

}
