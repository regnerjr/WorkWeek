import UIKit

class WorkDayCellTableViewCell: UITableViewCell {

    @IBOutlet weak var workTIme: UILabel!
    @IBOutlet weak var arrivalTime: UILabel!
    @IBOutlet weak var departureTime: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
