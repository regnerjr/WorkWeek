import UIKit
import CoreLocation

enum StoryBoardSegues: String {
    case Map = "MapViewSegue"
    case Settings = "settingsSegue"
}

class TableViewController: UITableViewController {
    
    lazy var workManager: WorkManager = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.workManager
    }()


    var array = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.title = "WorkWeek"
        //set ourselves as the location Manager delegate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.locationManager.delegate = self
    }
    override func viewWillAppear(animated: Bool) {
        array = workManager.allItems()
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = array[indexPath.row]
        return cell
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