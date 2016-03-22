import UIKit
import CoreLocation

enum StoryBoardSegues: String {
    case Map = "MapViewSegue"
    case Settings = "settingsSegue"
}

enum ReuseIdentifiers: String {
    case Header = "HeaderView"
    case MainCell = "MainCell"
    case Footer = "FooterView"
}

public class TableViewController: UITableViewController {

    let appDelegate = UIApplication.sharedApplication().del
    public var workManager: WorkManager {
        return appDelegate.workManager
    }
    var locationManager: LocationManager {
        return appDelegate.locationManager
    }
    var array = [WorkDay]()

    override public func viewDidLoad() {
        tableView.registerClass(FooterTableView.self,
                                forHeaderFooterViewReuseIdentifier: ReuseIdentifiers.Footer)
        navigationController?.title = "WorkWeek"

        locationManager.manager.startUpdatingLocation()
        configureTimerToReloadTheTableViewEveryMinute()

        // check if at least one location is monitored, else we should
        // transition to the map view so that the user can set a work
        // location and begin using the app
        if locationManager.monitoredRegions?.count == 0 {
            performSegueWithIdentifier(StoryBoardSegues.Map.rawValue, sender: self)
        }
        listenForNotifications()
    }

    deinit {
        stopListeningToNotifications()
    }

    func listenForNotifications(
            center: NSNotificationCenter = NSNotificationCenter.defaultCenter()) {
        center.addObserver(self, selector: #selector(reloadTableViewNotification(_:)),
                           name: "WorkWeekUpdated", object: nil)
        center.addObserver(self, selector: #selector(reloadTableViewNotification(_:)),
                           name: "UIApplicationDidBecomeActiveNotification", object: nil)
    }

    func stopListeningToNotifications(
            center: NSNotificationCenter = NSNotificationCenter.defaultCenter()) {
        center.removeObserver(self)
    }

    func reloadTableViewNotification(note: NSNotification) {
        print("Reloading TableView Due to Notification")
        array = workManager.allItems()
        tableView.reloadData()
    }

    override public func viewWillAppear(animated: Bool) {
        array = workManager.allItems()
        tableView.reloadData()
    }

    // MARK: - Navigation
    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {
        tableView.reloadData()
    }

    // MARK: - Helper Functions
    func configureTimerToReloadTheTableViewEveryMinute() {
        NSTimer.scheduledTimerWithTimeInterval(60.0, target: self,
                                               selector: #selector(reloadTableViewNotification(_:)),
                                               userInfo: nil, repeats: true)
    }

    func reloadTableView(timer: NSTimer) {
        print("Reloading table view due to timer")
        //for now get new data too!
        array = workManager.allItems()
        tableView.reloadData()
    }
}

//MARK: - TableViewDelegate
extension TableViewController {

    override public func tableView(tableView: UITableView,
                                   heightForHeaderInSection section: Int) -> CGFloat {
        return floor(UIScreen.mainScreen().bounds.height / 5)
    }

    override public func tableView(tableView: UITableView,
                                   heightForFooterInSection section: Int) -> CGFloat {
        if workManager.isAtWork {
            return 80
        } else {
            return 0
        }
    }

    override public func tableView(tableView: UITableView,
                                   viewForFooterInSection section: Int) -> UIView? {

        guard workManager.isAtWork == true  else { return nil }

        let footer = tableView.dequeueReusableHeaderFooterViewWithIdentifier(
                                                        ReuseIdentifiers.Footer)
        guard let footerView = footer as? FooterTableView else { return nil }
        footerView.configureWithLastArrival(workManager.lastArrival)
        return footerView
    }

    override public func tableView(tableView: UITableView,
                                   viewForHeaderInSection section: Int) -> UIView? {
        if let header = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifiers.Header) {
            let graph = header.contentView.subviews[0] as? HeaderView
            graph?.hoursInWeek = Defaults.standard.integerForKey(.HoursInWorkWeek)
            //loss of precision to draw the graph using only hour marks.
            graph?.hoursWorked = Int(workManager.hoursWorkedThisWeek +
                                     workManager.hoursSoFarToday())
            graph?.hoursLabel.text = String(graph?.hoursWorked)
            return header
        } else {
            return nil
        }
    }
}
