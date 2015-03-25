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
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate

    override func viewDidLoad() {
        navigationController?.title = "WorkWeek"

        //set ourselves as the location Manager delegate
        appDelegate.locationManager.delegate = self

        // check if at least one location is monitored, else we should 
        // transition to the map view so that the user can set a work location and begin using the app
        if appDelegate.locationManager.monitoredRegions.count == 0 {
            performSegueWithIdentifier(StoryBoardSegues.Map.rawValue, sender: self)
        }

       appDelegate.locationManager.startUpdatingLocation()
    }

    override func viewWillAppear(animated: Bool) {
//        let workHours = Defaults.standard.integerForKey(SettingsKey.hoursInWorkWeek)
        array = workManager.allItems()
        tableView.reloadData()
    }

    // MARK: - Navigation

    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {
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
        return 80
    }

    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let footer = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifiers.footerCell.rawValue) as UITableViewCell? {
            footer.contentView.backgroundColor = OverlayColor.Fill
            if workManager.isAtWork() {
                //get the current work time
                if let lastArrival = workManager.eventsForTheWeek.lastObject as? Event {
                    if lastArrival.inOrOut == .Arrival {
                        footer.textLabel?.text = "At Work: " + lastArrival.date.dayOfWeek
                    }
                }
            } else {
                footer.textLabel?.text = ""
            }

            return footer
        } else { //if we can't deque a Reusable Cell, just fail gracefully with a View with a white background
            let defaultfooter = UIView()
            defaultfooter.backgroundColor = UIColor.whiteColor()
            return defaultfooter
        }

    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if let header = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifiers.headerCell.rawValue) as UITableViewCell? {
            let graph = header.contentView.subviews[0] as HeaderView
            graph.hoursInWeek = Defaults.standard.integerForKey(SettingsKey.hoursInWorkWeek)
            graph.hoursWorked = Int(workManager.hoursWorkedThisWeek) //loss of precision to draw the graph using only hour marks.
            graph.hoursLabel.text = String(graph.hoursWorked)
            return header
        } else {
            let defaultHeader = UIView()
            defaultHeader.backgroundColor = UIColor.redColor()
            return defaultHeader
        }
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
