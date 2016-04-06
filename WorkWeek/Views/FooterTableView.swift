import UIKit

class FooterTableView: UITableViewHeaderFooterView {

    let atWorkLabel = UILabel(frame: .zero)
    let arrivedTimeLabel = UILabel(frame: .zero)
    let timeSoFarLabel = UILabel(frame: .zero)


    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addContentViews()
        contentView.backgroundColor = OverlayColor.Fill
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addContentViews()
        contentView.backgroundColor = OverlayColor.Fill
        print("Init With Coder Called")
    }

    override func layoutSubviews() {
        constrainArrivedLabel()
        constrainTimeSoFarLabel()
        constrainAtWorkLabel()
    }

    func configureWithLastArrival(lastArrival: Event?) {
        guard let lastArrival = lastArrival else {
            contentView.backgroundColor = .clearColor()
            return
        }
        atWorkLabel.text = "At Work: " + lastArrival.date.dayOfWeek
        arrivedTimeLabel.text = lastArrival.timeString
        timeSoFarLabel.text = Formatter.double
                              .stringFromDouble(lastArrival.timeSinceEventHoursDouble)
    }

    func constrainArrivedLabel() {
        arrivedTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[arrived]-|", options: [], metrics: nil,
            views: ["arrived": arrivedTimeLabel, "contentView": contentView]
            ).forEach {$0.active = true}
        NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-[arrived]", options: [], metrics: nil,
            views: ["arrived": arrivedTimeLabel, "contentView": contentView]
            ).forEach {$0.active = true}
    }

    func constrainTimeSoFarLabel() {
        timeSoFarLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[time]-|", options: [], metrics: nil,
            views: ["time": timeSoFarLabel, "contentView": contentView]
            ).forEach {$0.active = true}
        NSLayoutConstraint.constraintsWithVisualFormat(
            "H:[time]-|", options: [], metrics: nil,
            views: ["time": timeSoFarLabel, "contentView": contentView]
            ).forEach {$0.active = true}
    }

    func constrainAtWorkLabel() {
        atWorkLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateConstraints([
        atWorkLabel.centerXAnchor
                   .constraintEqualToAnchor(contentView.centerXAnchor),
        atWorkLabel.centerYAnchor
                   .constraintEqualToAnchor(contentView.centerYAnchor)
        ])
    }


    func addContentViews() {
        contentView.addSubview(atWorkLabel)
        contentView.addSubview(arrivedTimeLabel)
        contentView.addSubview(timeSoFarLabel)
    }
}
