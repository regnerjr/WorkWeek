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
            _ identifier: ReuseIdentifiers) -> UITableViewHeaderFooterView? {
        return self.dequeueReusableHeaderFooterView(withIdentifier: identifier.rawValue)
    }

    func registerClass(_ aClass: AnyClass?,
                       forHeaderFooterViewReuseIdentifier identifier: ReuseIdentifiers) {
        return self.register(aClass, forHeaderFooterViewReuseIdentifier: identifier.rawValue)

    }

    @available(*, deprecated, message: "Use the one with `indexPath`")
    func dequeueReusableCellWithIdentifier(_ identifier: ReuseIdentifiers) -> UITableViewCell? {
        return self.dequeueReusableCell(withIdentifier: identifier.rawValue)
    }

    func dequeueReusableCellWithIdentifier(_ identifier: ReuseIdentifiers,
                                           forIndexPath indexPath: IndexPath) -> UITableViewCell {
        return dequeueReusableCell(withIdentifier: identifier.rawValue, for: indexPath)
    }

}
