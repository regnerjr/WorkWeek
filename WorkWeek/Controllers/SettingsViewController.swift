import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var workHoursTextField: WorkHoursTextField!
    @IBOutlet weak var stepper: Stepper!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var workRadiusField: WorkRadiusTextField!

    let pickerSource = DayTimePicker()

    var defaultWorkHours: Int {
        get { return Defaults.standard.integerForKey(SettingsKey.hoursInWorkWeek) }
        set {
            Defaults.standard.setInteger(newValue, forKey: SettingsKey.hoursInWorkWeek)
            //If the number of work hours in a week changes, need to reschedule the end of the week Notification
            let hoursWorked = (UIApplication.sharedApplication().delegate as AppDelegate).workManager.hoursWorkedThisWeek
            let total = newValue
            LocalNotifier.setupNotification(hoursWorked, total: total)
        }
    }

    var defaultResetDay: Int {
        get { return Defaults.standard.integerForKey(SettingsKey.resetDay) }
        set {
            Defaults.standard.setInteger(newValue, forKey: SettingsKey.resetDay)
            //configure the reset timer to use the new hour
            let ad = UIApplication.sharedApplication().delegate as AppDelegate
            ad.setupATimerToClearTheWeeklyResults()
        }
    }
    var defaultResetHour: Int {
        get { return Defaults.standard.integerForKey(SettingsKey.resetHour) }
        set {
            Defaults.standard.setInteger(newValue, forKey:SettingsKey.resetHour)
            //configure the reset timer to use the new hour
            let ad = UIApplication.sharedApplication().delegate as AppDelegate
            ad.setupATimerToClearTheWeeklyResults()
        }
    }
    var defaultWorkRadius: Int {
        get{ return Defaults.standard.integerForKey(SettingsKey.workRadius) }
        set{ Defaults.standard.setInteger(newValue, forKey: SettingsKey.workRadius) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        picker.delegate = pickerSource
        picker.dataSource = pickerSource
        //set up picker based on defaults
        picker.selectRow(defaultResetDay, inComponent: 0, animated: false)
        picker.selectRow(defaultResetHour, inComponent: 1, animated: false)

        //populate fields with data from defaults
        workHoursTextField.workHours = defaultWorkHours
        stepper.workHours = defaultWorkHours
        workRadiusField.workRadius = defaultWorkRadius
    }

    override func viewWillDisappear(animated: Bool) {
        //update the pickerDefaults and set up the notification
        //could handle these in the delegate, but it is easier here, and the logic is small
        defaultResetDay = picker.selectedRowInComponent(0)
        defaultResetHour = picker.selectedRowInComponent(1)
    }

    @IBAction func launchSystemSettings(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }

    @IBAction func stepWorkHours(sender: Stepper) {
        //change the value stored in the label
        workHoursTextField.workHours = sender.workHours
        defaultWorkHours = sender.workHours
    }

    @IBAction func screenTapGesture(sender: UITapGestureRecognizer) {
        //find any fields that are editing, end editing then resign first responder
        let fields = [workHoursTextField, workRadiusField ]
        fields.filter{ $0.isFirstResponder() }
              .map{$0.endEditing(true)}
        resignFirstResponder()
    }

    @IBAction func doneEditing(sender: UITextField){
        if sender.text == "" {
            resetTextFieldWithDefault(sender)
        } else {
            saveNewValueInDefaults(sender)
        }
    }

    func resetTextFieldWithDefault(sender : UITextField){
        switch sender {
        case let s as WorkHoursTextField : s.workHours = defaultWorkHours
        case let s as WorkRadiusTextField: s.workRadius = defaultWorkRadius
        default: println("Something is wrong!!! Switching on a UITextField with unknown placeholder")
        }
    }

    func saveNewValueInDefaults(sender: UITextField) {
        switch sender {
        case let s as WorkHoursTextField:  defaultWorkHours = s.workHours
        case let s as WorkRadiusTextField: defaultWorkRadius = s.workRadius
        default: println("Something is wrong!!! Switching on a UITextField with unknown placeholder")
        }
    }
}