import UIKit

class SettingsViewController: UIViewController, UIPickerViewDelegate {

    @IBOutlet weak var workHoursTextField: WorkHoursTextField!
    @IBOutlet weak var stepper: Stepper!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var workRadiusField: WorkRadiusTextField!
    @IBOutlet weak var resetDateLabel: UILabel!

    let pickerSource = DayTimePicker()

    var defaultWorkHours: Int {
        get { return Defaults.standard.integerForKey(.hoursInWorkWeek) }
        set (hoursInFullWeek){
            Defaults.standard.setInteger(hoursInFullWeek, forKey: .hoursInWorkWeek)
            //If the number of work hours in a week changes, need to reschedule the end of the week Notification
            let wm = (UIApplication.sharedApplication().delegate as! AppDelegate).workManager
            wm.localNotificationHandler.setupNotification(wm.hoursWorkedThisWeek, hoursInFullWorkWeek: hoursInFullWeek)
        }
    }

    var defaultResetDay: Int {
        get { return Defaults.standard.integerForKey(.resetDay) }
        set {
            Defaults.standard.setInteger(newValue, forKey: .resetDay)
            updateDefaultResetDate()
        }
    }
    var defaultResetHour: Int {
        get { return Defaults.standard.integerForKey(.resetHour) }
        set {
            Defaults.standard.setInteger(newValue, forKey:.resetHour)
            updateDefaultResetDate()
        }
    }
    var defaultWorkRadius: Int {
        get{ return Defaults.standard.integerForKey(.workRadius) }
        set{ Defaults.standard.setInteger(newValue, forKey: .workRadius) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setPickerDelegateAndDataSource()
        setPickerToDefaultRows()
        setTextFieldsAndSteppersToDefauls()

    }

    override func viewWillAppear(animated: Bool) {
        let fmt = NSDateFormatter()
        fmt.timeStyle = NSDateFormatterStyle.ShortStyle
        fmt.dateStyle = NSDateFormatterStyle.ShortStyle
        if let date = Defaults.standard.objectForKey(.clearDate) as? NSDate {
            resetDateLabel.text = fmt.stringFromDate(date)
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        defaultResetDay = picker.selectedRowInComponent(0)
        defaultResetHour = picker.selectedRowInComponent(1)
    }

    @IBAction func launchSystemSettings(sender: UIButton) {
        UIApplication.sharedApplication().openSettings()
    }

    @IBAction func stepWorkHours(sender: Stepper) {
        //change the value stored in the label
        workHoursTextField.workHours = sender.workHours
        defaultWorkHours = sender.workHours
    }

    @IBAction func screenTapGesture(sender: UITapGestureRecognizer) {
        //find any fields that are editing, end editing then resign first responder
        [workHoursTextField, workRadiusField ]
            .filter{ $0.isFirstResponder() }
            .forEach{ $0.endEditing(true) }
        resignFirstResponder()
    }

    @IBAction func doneEditing(sender: UITextField){
        if sender.text == "" {
            resetTextFieldWithDefault(sender)
        } else {
            saveNewValueInDefaults(sender)
        }
    }

    @IBAction func doneOnboarding(sender: UIBarButtonItem) {
        viewWillDisappear(true)
        Defaults.standard.setBool(true, forKey: SettingsKey.onboardingComplete.rawValue)
        let ad = UIApplication.sharedApplication().delegate as? AppDelegate
        ad?.loadInterface()
    }

    func setPickerDelegateAndDataSource(){
        picker.delegate = pickerSource
        picker.dataSource = pickerSource
        pickerSource.dateLabel = resetDateLabel
    }

    func setPickerToDefaultRows(){
        picker.selectRow(defaultResetDay, inComponent: 0, animated: false)
        picker.selectRow(defaultResetHour, inComponent: 1, animated: false)
    }

    func setTextFieldsAndSteppersToDefauls(){
        workHoursTextField.workHours = defaultWorkHours
        stepper.workHours = defaultWorkHours
        workRadiusField.workRadius = defaultWorkRadius
    }

    func resetTextFieldWithDefault(sender: UITextField){
        switch sender {
        case let s as WorkHoursTextField: s.workHours = defaultWorkHours
        case let s as WorkRadiusTextField: s.workRadius = defaultWorkRadius
        default: print("Something is wrong!!! Switching on a UITextField with unknown placeholder")
        }
    }

    func saveNewValueInDefaults(sender: UITextField) {
        switch sender {
        case let s as WorkHoursTextField:  defaultWorkHours = s.workHours
        case let s as WorkRadiusTextField: defaultWorkRadius = s.workRadius
        default: print("Something is wrong!!! Switching on a UITextField with unknown placeholder")
        }
    }
}
