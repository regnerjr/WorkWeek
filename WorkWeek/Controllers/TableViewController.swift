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

class TableViewController: UITableViewController {

    lazy var workManager: WorkManager = {
        return self.appDelegate.workManager
    }()

    var array = [WorkDay]()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    override func viewDidLoad() {
        navigationController?.title = "WorkWeek"

        //set ourselves as the location Manager delegate
        appDelegate.locationManager.delegate = self

        appDelegate.locationManager.startUpdatingLocation()

        configureTimerToReloadTheTableViewEveryMinute()

        // check if at least one location is monitored, else we should 
        // transition to the map view so that the user can set a work location and begin using the app
        if appDelegate.locationManager.monitoredRegions.count == 0 {
            performSegueWithIdentifier(StoryBoardSegues.Map.rawValue, sender: self)
        }
    }

    override func viewWillAppear(animated: Bool) {
        array = workManager.allItems()
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
        self.tableView.reloadData()
    }
}

//MARK: - TableViewDelegate
extension TableViewController: UITableViewDelegate {

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 150
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }

    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if workManager.isAtWork() {
            return 80
        } else {
            return 1
        }
    }

    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let footer = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifiers.footerCell.rawValue) as! FooterTableViewCell? {
            if workManager.isAtWork() {
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
                footer.AtWorkLabel.text = ""
                footer.ArrivedTimeLabel.text = ""
                footer.timeSoFarLabel.text = ""
                footer.activityIndicator.stopAnimating()
            }

            return footer
        } else { //if we can't deque a Reusable Cell, just fail gracefully with a View with a white background
            let defaultfooter = UIView()
            defaultfooter.backgroundColor = UIColor.whiteColor()
            return defaultfooter
        }
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifiers.headerCell.rawValue) as! UITableViewCell? {
            let graph = header.contentView.subviews[0] as! HeaderView
            graph.hoursInWeek = Defaults.standard.integerForKey(SettingsKey.hoursInWorkWeek)
            graph.hoursWorked = Int(workManager.hoursWorkedThisWeek + hoursSoFarToday()) //loss of precision to draw the graph using only hour marks.
            graph.hoursLabel.text = String(graph.hoursWorked)
            return header
        } else {
            let defaultHeader = UIView()
            defaultHeader.backgroundColor = UIColor.redColor()
            return defaultHeader
        }
    }

    func hoursSoFarToday() -> Double{
        if let lastArrival = workManager.eventsForTheWeek.lastObject as? Event {
            if lastArrival.inOrOut == .Arrival {
                let (h,m) = hoursMinutesFromDate(date: lastArrival.date, toDate: NSDate())
                let hoursToday = getDoubleFrom(hours: h, min: m)
                return hoursToday
            }
        }
        return 0
    }

}

//MARK: - Location Manager Delegate
extension TableViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        if region.identifier == MapRegionIdentifiers.work {
            println( "Arrived at work")
            workManager.addArrival(NSDate())
            array = workManager.allItems()
            tableView.reloadData()
        }
    }
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        if region.identifier == MapRegionIdentifiers.work {
            println("Leaving work")
            workManager.addDeparture(NSDate())
            array = workManager.allItems()
            tableView.reloadData()
        }
    }
}
