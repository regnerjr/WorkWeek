import UIKit

class FooterTableView: UIView {

    @IBOutlet var atWorkLabel: UILabel!
    @IBOutlet var arrivedTimeLabel: UILabel!
    @IBOutlet var timeSoFarLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = OverlayColor.Fill
    }

    func configureWithLastArrival(_ lastArrival: Event?) {
        guard let lastArrival = lastArrival else {
            backgroundColor = .clear
            return
        }
        atWorkLabel.text = "At Work: " + lastArrival.dayOfWeek
        arrivedTimeLabel.text = lastArrival.timeString
        timeSoFarLabel.text = lastArrival.timeSoFar
    }

}
