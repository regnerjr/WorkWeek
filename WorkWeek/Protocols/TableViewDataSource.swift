import UIKit

extension TableViewController {

    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override public func tableView(tableView: UITableView,
                                   numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return workManager.allItems().count
        }
        return 0
    }

    override public func tableView(tableView: UITableView,
                                   cellForRowAtIndexPath indexPath: NSIndexPath
                                  ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier(
            ReuseIdentifiers.MainCell, forIndexPath: indexPath)
        guard let workDayCell = cell as? WorkDayCellTableViewCell else {
            assert(cell is WorkDayCellTableViewCell, "Cell is not WorkDayCellTableViewCell")
            return cell // return unconfigured cell
        }

        let workItem = workManager.allItems()[indexPath.row]
        workDayCell.workDate?.text = workItem.weekDay
        workDayCell.workTime?.text = workItem.decimalHoursWorked
        workDayCell.arrivalTime.text = workItem.arrivalTime
        workDayCell.departureTime.text = workItem.departureTime

        return workDayCell
    }

}
