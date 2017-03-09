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

open class TableViewController: UITableViewController {

    @IBOutlet var footer: FooterTableView!

    let appDelegate = UIApplication.shared.del
    var workManager: WorkManager {
        return appDelegate.workManager
    }
    var locationManager: LocationManager {
        return appDelegate.locationManager
    }
    var array = [WorkDay]()

    override open func viewDidLoad() {
        navigationController?.title = "WorkWeek"

        locationManager.manager.startUpdatingLocation()
        configureTimerToReloadTheTableViewEveryMinute()

        // check if at least one location is monitored, else we should
        // transition to the map view so that the user can set a work
        // location and begin using the app
        if locationManager.monitoredRegions.count == 0 {
            performSegue(withIdentifier: StoryBoardSegues.Map.rawValue, sender: self)
        }
        listenForNotifications()
    }

    deinit {
        stopListeningToNotifications()
    }

    func listenForNotifications(
            _ center: NotificationCenter = NotificationCenter.default) {
        center.addObserver(self, selector: #selector(reloadTableViewNotification(_:)),
                           name: NSNotification.Name(rawValue: "WorkWeekUpdated"), object: nil)
        center.addObserver(self, selector: #selector(reloadTableViewNotification(_:)),
                           name: NSNotification.Name(rawValue: "UIApplicationDidBecomeActiveNotification"), object: nil)
    }

    func stopListeningToNotifications(
            _ center: NotificationCenter = NotificationCenter.default) {
        center.removeObserver(self)
    }

    func reloadTableViewNotification(_ note: Notification) {
        print("Reloading TableView Due to Notification")
        array = workManager.allItems()
        print("\(array.count)")
        tableView.reloadData()
    }

    override open func viewWillAppear(_ animated: Bool) {
        array = workManager.allItems()
        tableView.reloadData()
    }

    // MARK: - Navigation
    @IBAction func unwindToThisViewController(_ segue: UIStoryboardSegue) {
        tableView.reloadData()
    }

    // MARK: - Helper Functions
    func configureTimerToReloadTheTableViewEveryMinute() {
        Timer.scheduledTimer(timeInterval: 60.0, target: self,
                             selector: #selector(reloadTableView(_:)),
                                               userInfo: nil, repeats: true)
    }

    func reloadTableView(_ timer: Timer) {
        print("Reloading table view due to timer")
        //for now get new data too!
        array = workManager.allItems()
        print("\(array.count)")
        tableView.reloadData()
    }
}

// MARK: - TableViewDelegate
extension TableViewController {

    override open func tableView(_ tableView: UITableView,
                                 heightForHeaderInSection section: Int) -> CGFloat {
        return floor(UIScreen.main.bounds.height / 5)
    }

    override open func tableView(_ tableView: UITableView,
                                 heightForFooterInSection section: Int) -> CGFloat {
        if workManager.isAtWork {
            return 80
        } else {
            return 0
        }
    }

    override open func tableView(_ tableView: UITableView,
                                 viewForFooterInSection section: Int) -> UIView? {

        guard workManager.isAtWork == true  else { return nil }

        var tableFooter = tableView.dequeueReusableHeaderFooterViewWithIdentifier(
                                ReuseIdentifiers.Footer)
        if tableFooter == nil {
            tableView.register(UITableViewHeaderFooterView.self,
                               forHeaderFooterViewReuseIdentifier: ReuseIdentifiers.Footer.rawValue)

            tableFooter = UITableViewHeaderFooterView(reuseIdentifier: ReuseIdentifiers.Footer.rawValue)
        }
        footer.configureWithLastArrival(workManager.lastArrival)

        tableFooter?.contentView.addSubview(footer)

        return footer

    }

    override open func tableView(_ tableView: UITableView,
                                 viewForHeaderInSection section: Int) -> UIView? {
        if let header = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifiers.Header.rawValue) {
            let graph = header.contentView.subviews[0] as? HeaderView
            graph?.hoursInWeek = Defaults.standard.integerForKey(.HoursInWorkWeek)
            //loss of precision to draw the graph using only hour marks.
            graph?.hoursWorked = Int(workManager.hoursWorkedThisWeek +
                                     workManager.hoursSoFarToday())
            graph?.hoursLabel.text = String(graph?.hoursWorked ?? 0)
            return header
        } else {
            return nil
        }
    }
}
