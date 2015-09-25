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
    
    func configureWithLastArrival(lastArrival: Event?){
        guard let lastArrival = lastArrival else {
            contentView.backgroundColor = .clearColor()
            return 
        }
        atWorkLabel.text = "At Work: " + lastArrival.date.dayOfWeek
        arrivedTimeLabel.text = lastArrival.timeString
        timeSoFarLabel.text = Formatter.double.stringFromDouble(lastArrival.timeSinceEventHoursDouble)
    }

    func addContentViews(){
        func insertLabelsIntoViewHierarchy(){
            contentView.addSubview(atWorkLabel)
            contentView.addSubview(arrivedTimeLabel)
            contentView.addSubview(timeSoFarLabel)
        }
        insertLabelsIntoViewHierarchy()

        func constrainArrivedLabel(){
            arrivedTimeLabel.translatesAutoresizingMaskIntoConstraints = false
            let vconstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[arrived]-|", options: [], metrics: nil, views: ["arrived": arrivedTimeLabel, "contentView": contentView])
            let hconstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[arrived]", options: [], metrics: nil, views: ["arrived": arrivedTimeLabel, "contentView": contentView])
            NSLayoutConstraint.activateConstraints(vconstraints)
            NSLayoutConstraint.activateConstraints(hconstraints)
        }
        constrainArrivedLabel()

        func constrainTimeSoFarLabel(){
            timeSoFarLabel.translatesAutoresizingMaskIntoConstraints = false
            let vconstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[time]-|", options: [], metrics: nil, views: ["time": timeSoFarLabel, "contentView": contentView])
            let hconstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[time]-|", options: [], metrics: nil, views: ["time": timeSoFarLabel, "contentView": contentView])
            NSLayoutConstraint.activateConstraints(vconstraints)
            NSLayoutConstraint.activateConstraints(hconstraints)
        }
        constrainTimeSoFarLabel()

        func constrainAtWorkLabel(){
            atWorkLabel.translatesAutoresizingMaskIntoConstraints = false
            let centerX = NSLayoutConstraint(item: atWorkLabel,
                                attribute: NSLayoutAttribute.CenterX,
                                relatedBy: NSLayoutRelation.Equal,
                                toItem: contentView,
                                attribute: NSLayoutAttribute.CenterX,
                                multiplier: 1, constant: 0)
            let centerY = NSLayoutConstraint(item: atWorkLabel, attribute: NSLayoutAttribute.CenterY,
                                                relatedBy: NSLayoutRelation.Equal,
                                                toItem: contentView, attribute: NSLayoutAttribute.CenterY,
                                                multiplier: 1, constant: 0)
            centerX.active = true
            centerY.active = true
        }
        constrainAtWorkLabel()
    }
}
