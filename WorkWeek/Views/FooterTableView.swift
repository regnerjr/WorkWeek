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
    }

    override func layoutSubviews() {
        constrainArrivedLabel()
        constrainTimeSoFarLabel()
        constrainAtWorkLabel()
    }

    func configureWithLastArrival(_ lastArrival: Event?) {
        guard let lastArrival = lastArrival else {
            contentView.backgroundColor = .clear
            return
        }
        atWorkLabel.text = "At Work: " + lastArrival.dayOfWeek
        arrivedTimeLabel.text = lastArrival.timeString
    }

    func constrainArrivedLabel() {
        arrivedTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.constraints(
            withVisualFormat: "V:[arrived]-|", options: [], metrics: nil,
            views: ["arrived": arrivedTimeLabel, "contentView": contentView]
            ).forEach {$0.isActive = true}
        NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-[arrived]", options: [], metrics: nil,
            views: ["arrived": arrivedTimeLabel, "contentView": contentView]
            ).forEach {$0.isActive = true}
        timeSoFarLabel.text = lastArrival.timeSoFar
    }

    func constrainTimeSoFarLabel() {
        timeSoFarLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.constraints(
            withVisualFormat: "V:[time]-|", options: [], metrics: nil,
            views: ["time": timeSoFarLabel, "contentView": contentView]
            ).forEach {$0.isActive = true}
        NSLayoutConstraint.constraints(
            withVisualFormat: "H:[time]-|", options: [], metrics: nil,
            views: ["time": timeSoFarLabel, "contentView": contentView]
            ).forEach {$0.isActive = true}
    }

    func constrainAtWorkLabel() {
        atWorkLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
        atWorkLabel.centerXAnchor
                   .constraint(equalTo: contentView.centerXAnchor),
        atWorkLabel.centerYAnchor
                   .constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func addContentViews() {
        contentView.addSubview(atWorkLabel)
        contentView.addSubview(arrivedTimeLabel)
        contentView.addSubview(timeSoFarLabel)
    }
}
