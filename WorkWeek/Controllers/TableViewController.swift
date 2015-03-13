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
        //print the nsuserdefaults for testing
        let workHours = Defaults.standard.integerForKey(SettingsKey.hoursInWorkWeek)
        let lunchHours = Defaults.standard.doubleForKey(SettingsKey.unpaidLunchTime)
        array = workManager.allItems()
        tableView.reloadData()
    }

    // MARK: - Navigation

    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {
    }
}

//MARK: - TableViewDataSource
extension TableViewController: UITableViewDataSource {

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifiers.mainCell.rawValue, forIndexPath: indexPath) as WorkDayCellTableViewCell

        let workItem = array[indexPath.row]
        let decimalHoursWorked = Float(workItem.hoursWorked) +
                                 Float( workItem.minutesWorked / 60)
        cell.workDate?.text = workItem.weekDay
        cell.workTime?.text = Formatter.double.stringFromNumber( decimalHoursWorked ) ?? "" //leave it blank if nil
        cell.arrivalTime.text = workItem.arrivalTime
        cell.departureTime.text = workItem.departureTime

        return cell
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
            if workManager.isAtWork() {
                //get the current work time
                if let lastArrival = workManager.eventsForTheWeek.last {
                    if lastArrival.inOrOut == .Arrival {
                        let currentWorkTime = hoursMinutesFromDate(date: lastArrival.date, toDate: NSDate())
                        let workHours = Double(currentWorkTime.hours) + (Double(currentWorkTime.minutes) / 60)
                        footer.textLabel?.text = "At Work: " + lastArrival.date.dayOfWeek
                        footer.detailTextLabel?.text = Formatter.double.stringFromNumber(workHours)
                    }
                }
            } else {
                footer.textLabel?.text = ""
                footer.detailTextLabel?.text = ""
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
            self.workManager.addArrival(NSDate())
            self.array = workManager.allItems()
            self.tableView.reloadData()
        }
    }
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        if region.identifier == MapRegionIdentifiers.work {
            println("Leaving work")
            self.workManager.addDeparture(NSDate())
            self.array = workManager.allItems()
            self.tableView.reloadData()
        }
    }
}
