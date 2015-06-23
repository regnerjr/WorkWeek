import UIKit
import CoreLocation

enum StoryBoardSegues: String {
    case Map = "MapViewSegue"
    case Settings = "settingsSegue"
}

enum ReuseIdentifiers: String {
    case headerCell = "headerView"
    case mainCell = "mainCell"
    case footerCell = "footerView"
}

public class TableViewController: UITableViewController {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    public var workManager: WorkManager {
        return appDelegate.workManager
    }
    var locationManager: LocationManager {
        return appDelegate.locationManager
    }
    var array = [WorkDay]()

    override public func viewDidLoad() {
        navigationController?.title = "WorkWeek"

        locationManager.manager.startUpdatingLocation()
        configureTimerToReloadTheTableViewEveryMinute()

        // check if at least one location is monitored, else we should 
        // transition to the map view so that the user can set a work location and begin using the app
        if locationManager.monitoredRegions?.count == 0 {
            performSegueWithIdentifier(StoryBoardSegues.Map.rawValue, sender: self)
        }
        listenForNotifications()
    }

    deinit {
        stopListeningToNotifications()
    }

    func listenForNotifications(center: NSNotificationCenter = NSNotificationCenter.defaultCenter()){
        center.addObserver(self, selector: "reloadTableViewNotification:", name: "WorkWeekUpdated", object: nil)
    }

    func stopListeningToNotifications(center: NSNotificationCenter = NSNotificationCenter.defaultCenter()){
        center.removeObserver(self)
    }

    func reloadTableViewNotification(note: NSNotification){
        print("Reloading TableView Due to Notification")
        tableView.reloadData()
    }

    override public func viewWillAppear(animated: Bool) {
        array = workManager.allItems()
        if array.count == 0 {
            //no items to display, this is fine.... except if the user is at work now?
            //then we will force an arrival
            // force an ar
//            workManager.addArrivalIfAtWork(locationManager)
        }
        tableView.reloadData()
    }

    // MARK: - Navigation
    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {
        tableView.reloadData()
    }

    // MARK: - Helper Functions
    func configureTimerToReloadTheTableViewEveryMinute(){
        NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: "reloadTableView:", userInfo: nil, repeats: true)
    }

    func reloadTableView(timer: NSTimer){
        print("Reloading table view due to timer")
        self.tableView.reloadData()
    }
}

//MARK: - TableViewDelegate
extension TableViewController {

    override public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //TODO: Convert this to be a fraction of the screen height instead of a constant, This will help thing look better on smaller phones
        return 150
    }

    override public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    public override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }

    override public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if workManager.isAtWork {
            return 80
        } else {
            return 0
        }
    }

    override public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let footer = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifiers.footerCell.rawValue) as! FooterTableViewCell? {
            if workManager.isAtWork {
                footer.contentView.backgroundColor = OverlayColor.Fill
                //get the current work time
                if let lastArrival = workManager.eventsForTheWeek.lastObject as? Event {
                    if lastArrival.inOrOut == .Arrival {
                        footer.AtWorkLabel.text = "At Work: " + lastArrival.date.dayOfWeek
                        footer.ArrivedTimeLabel.text = Formatter.shortTime.stringFromDate(lastArrival.date)
                        footer.activityIndicator.startAnimating()
                        let (h,m) = hoursMinutesFromDate(date: lastArrival.date, toDate: NSDate())
                        footer.timeSoFarLabel.text = Formatter.double.stringFromDouble(getDoubleFrom(hours: h, min: m))
                    }
                }
            } else {
                footer.activityIndicator.stopAnimating()
            }

            return footer
        } else { //if we can't deque a Reusable Cell, just fail gracefully with a View with a white background
            let defaultfooter = UIView()
            defaultfooter.backgroundColor = UIColor.whiteColor()
            return defaultfooter
        }
    }

    override public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifiers.headerCell.rawValue) as UITableViewCell? {
            let graph = header.contentView.subviews[0] as! HeaderView
            graph.hoursInWeek = Defaults.standard.integerForKey(.hoursInWorkWeek)
            graph.hoursWorked = Int(workManager.hoursWorkedThisWeek + workManager.hoursSoFarToday()) //loss of precision to draw the graph using only hour marks.
            graph.hoursLabel.text = String(graph.hoursWorked)
            return header
        } else {
            let defaultHeader = UIView()
            defaultHeader.backgroundColor = .redColor()
            return defaultHeader
        }
    }
}
