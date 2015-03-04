//
//  WorkDayCellTableViewCell.swift
//  WorkWeek
//
//  Created by John Regner on 3/2/15.
//  Copyright (c) 2015 TRexTech. All rights reserved.
//

import UIKit

class WorkDayCellTableViewCell: UITableViewCell {

    @IBOutlet weak var workTIme: UILabel!
    @IBOutlet weak var arrivalTime: UILabel!
    @IBOutlet weak var departureTime: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
