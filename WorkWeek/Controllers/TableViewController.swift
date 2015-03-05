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


struct Settings {
    let hoursInWorkWeek: Int
}

class TableViewController: UITableViewController {

    lazy var workManager: WorkManager = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        return appDelegate.workManager
    }()

    //update the settings from disk? or use defaults
    //for now create a default set
    lazy var settings: Settings  = {
        return Settings(hoursInWorkWeek: 40)
    }()

    var array = [WorkDay]()

    override func viewDidLoad() {
        navigationController?.title = "WorkWeek"

        //set ourselves as the location Manager delegate
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.locationManager.delegate = self

        //check if at least one location is monitored, else we should transition to the map view so that the user can set a work location and begin using the app
        if appDelegate.locationManager.monitoredRegions.count == 0 {
            performSegueWithIdentifier(StoryBoardSegues.Map.rawValue, sender: self)
        }

    }

    override func viewWillAppear(animated: Bool) {
        array = workManager.allItems()
        tableView.reloadData()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        // Get the new view controller using [segue destinationViewController].
//        // Pass the selected object to the new view controller.
//
//        //we have 2 segues, SettingsSegue, and MapViewSegue
//        if segue.identifier == StoryBoardSegues.Map.rawValue{
//            println("transitioning to MapView")
//        } else if segue.identifier == StoryBoardSegues.Settings.rawValue {
//            println("transitioning to Settings")
//        }
    }

    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {
        println("unwinding: \(segue.identifier)")
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
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        let decimalHoursWorked = Float(workItem.hoursWorked) + Float( workItem.minutesWorked / 60)
        cell.workTIme?.text = workItem.weekDay + " " + ( formatter.stringFromNumber( decimalHoursWorked ) ?? "" ) //leave it blank if nil
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
            let graph = header.contentView.subviews[0] as HeaderView
            graph.hoursInWeek = settings.hoursInWorkWeek
            graph.hoursWorked = workManager.hoursWorkedThisWeek

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
