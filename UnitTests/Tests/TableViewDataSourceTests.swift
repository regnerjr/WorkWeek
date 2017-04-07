import XCTest

@testable import WorkWeek

class TableViewDataSourceTests: XCTestCase {

    var tableViewController: TableViewController!
    var tableView: UITableView!
    var manager: WorkManager!
    var appDelegate: AppDelegate!

    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let optVC = storyboard.instantiateViewController(withIdentifier: "TableViewController")
            as? TableViewController else {
                XCTFail("Can't Get Table View Controller"); return
        }
        tableViewController = optVC
        tableView = tableViewController.view as! UITableView //swiftlint:disable:this force_cast
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        manager = WorkManager()
        manager.clearEvents()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation
        // of each test method in the class.
        manager.clearEvents()
        manager = nil
        tableView = nil
        super.tearDown()
    }

    func testNumberOfSectionsIsOne() {
        XCTAssert(tableViewController.numberOfSections(in: tableView) == 1,
                  "1 Section in the tableView")
    }

    func testRowsInSectionZeroDependsOnModel() {
        manager.addArrival(Date())
        manager.addDeparture(Date()) //added one item

        appDelegate.workManager = manager
        let rows = tableViewController.tableView(tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(rows, 1, "1 row for one day of work")

        manager.addArrival(Date())
        manager.addDeparture(Date()) //add another entry
        appDelegate.workManager = manager
        let rows2 = tableViewController.tableView(tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(rows2, 2, "1 row for one day of work")

    }

    func testRowsInOtherSectionsIsZero() {
        manager.addArrival(Date())
        manager.addDeparture(Date())// add an item, should be displayed in section 0

        appDelegate.workManager = manager

        let rows = tableViewController.tableView(tableView, numberOfRowsInSection: 1)
        XCTAssertEqual(rows, 0, "Zero rows in undefined sections")

        let rows2 = tableViewController.tableView(tableView, numberOfRowsInSection: 2)
        XCTAssertEqual(rows2, 0, "Zero rows in undefined sections")

    }

    func DISABLED__testTableViewCellCreation() {
        //set timezone to get days and times correct
        NSTimeZone.default = TimeZone(secondsFromGMT: 0)!
        let arrivalTime = Date(timeIntervalSinceReferenceDate: 0) //jan 1 2001 at 12:00 AM
        manager.addArrival(arrivalTime)
        let departureTime = Date(timeIntervalSinceReferenceDate: 8*60*60 ) // 8 hours later
        manager.addDeparture(departureTime)
        appDelegate.workManager = manager

        //need an IndexPath to test this
        let indexPath = IndexPath(row: 0, section: 0)
        //we only added one item so far, it will be in row 1 of section 1
        tableView.reloadData()
        let cell = tableViewController.tableView(tableView, cellForRowAt: indexPath)
        let workCell = cell as? WorkDayCellTableViewCell

        XCTAssertEqual(workCell?.workDate!.text!, "Mon", "")
        XCTAssertEqual(workCell?.workTime!.text!, "8.0", "")
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = DateFormatter.Style.short
        //Fragile Tests, pro tip.. to fix these fragile tests, focus them... 
        // what are we really trying to test here? that if there is an arrival and departure in the work manager
        // that the cell labels are set correctly... then lets put an arrival and a departure in the tableView's
        // data source, and then load the table only with the fake data, no need to depend on the work manager
        // to do this test. 
        XCTAssertEqual(workCell?.arrivalTime!.text!, timeFormatter.string(from: arrivalTime), "")
        XCTAssertEqual(workCell?.departureTime!.text!, timeFormatter.string(from: departureTime),
                       "")

    }

}
