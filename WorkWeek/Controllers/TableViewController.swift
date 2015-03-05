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
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        return appDelegate.workManager
    }()


    var array = [WorkDay]()

    override func viewDidLoad() {
        navigationController?.title = "WorkWeek"

        //set ourselves as the location Manager delegate
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.locationManager.delegate = self

    }

    override func viewWillAppear(animated: Bool) {
        array = workManager.allItems()
        tableView.reloadData()
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }


    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 150
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifiers.mainCell.rawValue, forIndexPath: indexPath) as WorkDayCellTableViewCell

        let workItem = array[indexPath.row]
        cell.workTIme?.text = workItem.weekDay + ": " +
            String(workItem.hoursWorked) + " Hours, " +
            String(workItem.minutesWorked) + " Minutes"
        cell.arrivalTime.text = workItem.arrivalTime
        cell.departureTime.text = workItem.departureTime

        return cell
    }

    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        println("Called View For Footer in Section")
        if let footer = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifiers.footerCell.rawValue) as UITableViewCell? {

            footer.textLabel?.text = workManager.isAtWork() ? "Working :(" : "Enjoying a Balanced Life"
            return footer
        } else {
            let defaultfooter = UIView()
            defaultfooter.backgroundColor = UIColor.whiteColor()
            return defaultfooter
        }

    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        println("Called View for Header in Section")
        if let header = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifiers.headerCell.rawValue) as UITableViewCell? {
            return header
        } else {
            let defaultHeader = UIView()
            defaultHeader.backgroundColor = UIColor.redColor()
            return defaultHeader
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.

        //we have 2 segues, SettingsSegue, and MapViewSegue
        if segue.identifier == StoryBoardSegues.Map.rawValue{
            println("transitioning to MapView")
        } else if segue.identifier == StoryBoardSegues.Settings.rawValue {
            println("transitioning to Settings")
        }
    }

    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {
        println("unwinding: \(segue.identifier)")
    }
}

extension TableViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        if region.identifier == "WorkRegion" {
            println( "Arrived at work")
            self.workManager.addArrival(NSDate())
            self.array = workManager.allItems()
            self.tableView.reloadData()
        }
    }
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        if region.identifier == "WorkRegion" {
            println("Leaving work")
            self.workManager.addDeparture(NSDate())
            self.array = workManager.allItems()
            self.tableView.reloadData()
        }
    }
}
