import UIKit

//MARK: - UITableViewDataSource
extension TableViewController {

    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return workManager.allItems().count
        } else {
            return 0
        }
    }

    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifiers.mainCell.rawValue, forIndexPath: indexPath) as! WorkDayCellTableViewCell

        let workItem = workManager.allItems()[indexPath.row]
        cell.workDate?.text = workItem.weekDay
        cell.workTime?.text = workItem.decimalHoursWorked
        cell.arrivalTime.text = workItem.arrivalTime
        cell.departureTime.text = workItem.departureTime

        return cell
    }
    
}
