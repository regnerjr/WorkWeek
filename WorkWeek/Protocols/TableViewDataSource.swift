import UIKit

extension TableViewController: UITableViewDataSource {

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workManager.allItems().count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifiers.mainCell.rawValue, forIndexPath: indexPath) as WorkDayCellTableViewCell

        let workItem = workManager.allItems()[indexPath.row]
        let decimalHoursWorked = Float(workItem.hoursWorked) +
            Float( workItem.minutesWorked / 60)
        cell.workDate?.text = workItem.weekDay
        cell.workTime?.text = Formatter.double.stringFromNumber( decimalHoursWorked ) ?? "" //leave it blank if nil
        cell.arrivalTime.text = workItem.arrivalTime
        cell.departureTime.text = workItem.departureTime

        return cell
    }
    
}
