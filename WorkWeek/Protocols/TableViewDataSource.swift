import UIKit

extension TableViewController {

    override open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override open func tableView(_ tableView: UITableView,
                                 numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return workManager.allItems().count
        }
        return 0
    }

    override open func tableView(_ tableView: UITableView,
                                 cellForRowAt indexPath: IndexPath
                                  ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: ReuseIdentifiers.mainCell.rawValue, for: indexPath)
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
