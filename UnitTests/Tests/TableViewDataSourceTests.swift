import UIKit
import XCTest

import WorkWeek

class TableViewDataSourceTests: XCTestCase {

    var tableViewController: TableViewController!
    var tableView: UITableView!
    var manager: WorkManager!
    var appDelegate: AppDelegate!

    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        tableViewController = storyboard.instantiateViewControllerWithIdentifier("TableViewController") as! TableViewController
//        tableView = tableViewController.tableView
        tableView = tableViewController.view as! UITableView //load the view
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        manager = WorkManager()
        manager.clearEvents()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        manager.clearEvents()
        manager = nil
        tableView = nil
        super.tearDown()
    }

    func testNumberOfSectionsIsOne() {
        XCTAssert(tableViewController.numberOfSectionsInTableView(tableView) == 1, "1 Section in the tableView")
    }

    func testRowsInSectionZeroDependsOnModel(){
        manager.addArrival(NSDate())
        manager.addDeparture(NSDate()) //added one item

        appDelegate.workManager = manager
        let rows = tableViewController.tableView(tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(rows, 1, "1 row for one day of work")

        manager.addArrival(NSDate())
        manager.addDeparture(NSDate()) //add another entry
        appDelegate.workManager = manager
        let rows2 = tableViewController.tableView(tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(rows2, 2, "1 row for one day of work")

    }

    func testRowsInOtherSectionsIsZero(){
        manager.addArrival(NSDate())
        manager.addDeparture(NSDate())// add an item, should be displayed in section 0

        appDelegate.workManager = manager

        let rows = tableViewController.tableView(tableView, numberOfRowsInSection: 1)
        XCTAssertEqual(rows, 0, "Zero rows in undefined sections")

        let rows2 = tableViewController.tableView(tableView, numberOfRowsInSection: 2)
        XCTAssertEqual(rows2, 0, "Zero rows in undefined sections")

    }

    func testTableViewCellCreation(){
        //set timezone to get days and times correct
        NSTimeZone.setDefaultTimeZone(NSTimeZone(forSecondsFromGMT: 0))
        let arrivalTime = NSDate(timeIntervalSinceReferenceDate: 0) //jan 1 2001 at 12:00 AM
        manager.addArrival(arrivalTime)
        let departureTime = NSDate(timeIntervalSinceReferenceDate: 8*60*60 ) // 8 hours later
        manager.addDeparture(departureTime)
        appDelegate.workManager = manager

        //need an IndexPath to test this
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)//we only added one item so far, it will be in row 1 of section 1
        tableView.reloadData()
        let cell = tableViewController.tableView(tableView, cellForRowAtIndexPath: indexPath)
        let workCell = cell as! WorkDayCellTableViewCell

        XCTAssertEqual(workCell.workDate!.text!, "Mon", "")
        XCTAssertEqual(workCell.workTime!.text!, "8.0", "")
        let timeFormatter = NSDateFormatter(); timeFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        XCTAssertEqual(workCell.arrivalTime!.text!, timeFormatter.stringFromDate(arrivalTime), "")
        XCTAssertEqual(workCell.departureTime!.text!, timeFormatter.stringFromDate(departureTime), "")

    }

}
