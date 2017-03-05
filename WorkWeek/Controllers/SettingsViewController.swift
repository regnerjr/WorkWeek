import UIKit

class SettingsViewController: UIViewController, UIPickerViewDelegate {

    @IBOutlet weak var workHoursTextField: WorkHoursTextField!
    @IBOutlet weak var stepper: Stepper!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var workRadiusField: WorkRadiusTextField!
    @IBOutlet weak var resetDateLabel: UILabel!

    let pickerSource = DayTimePicker()

    var defaultWorkHours: Int {
        get { return Defaults.standard.integerForKey(.HoursInWorkWeek) }
        set (hoursInFullWeek) {
            Defaults.standard.setInteger(hoursInFullWeek, forKey: .HoursInWorkWeek)
            //If the number of work hours in a week changes, need to reschedule
            // the end of the week Notification
            let wm = (UIApplication.shared.del).workManager
            wm.localNotificationHandler.setupNotification(wm.hoursWorkedThisWeek,
                                                          hoursInFullWorkWeek: hoursInFullWeek)
        }
    }

    var defaultResetDay: Int {
        get { return Defaults.standard.integerForKey(.ResetDay) }
        set {
            Defaults.standard.setInteger(newValue, forKey: .ResetDay)
            updateDefaultResetDate()
        }
    }
    var defaultResetHour: Int {
        get { return Defaults.standard.integerForKey(.ResetHour) }
        set {
            Defaults.standard.setInteger(newValue, forKey:.ResetHour)
            updateDefaultResetDate()
        }
    }
    var defaultWorkRadius: Int {
        get { return Defaults.standard.integerForKey(.WorkRadius) }
        set { Defaults.standard.setInteger(newValue, forKey: .WorkRadius) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setPickerDelegateAndDataSource()
        setPickerToDefaultRows()
        setTextFieldsAndSteppersToDefauls()

    }

    override func viewWillAppear(_ animated: Bool) {
        let fmt = DateFormatter()
        fmt.timeStyle = DateFormatter.Style.short
        fmt.dateStyle = DateFormatter.Style.short
        if let date = Defaults.standard.objectForKey(.ClearDate) as? Date {
            resetDateLabel.text = fmt.string(from: date)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        defaultResetDay = picker.selectedRow(inComponent: 0)
        defaultResetHour = picker.selectedRow(inComponent: 1)
    }

    @IBAction func launchSystemSettings(_ sender: UIButton) {
        UIApplication.shared.openSettings()
    }

    @IBAction func stepWorkHours(_ sender: Stepper) {
        //change the value stored in the label
        workHoursTextField.workHours = sender.workHours
        defaultWorkHours = sender.workHours
    }

    @IBAction func screenTapGesture(_ sender: UITapGestureRecognizer) {
        //find any fields that are editing, end editing then resign first responder
        [workHoursTextField, workRadiusField ]
            .filter { $0.isFirstResponder }
            .forEach { $0.endEditing(true) }
        resignFirstResponder()
    }

    @IBAction func doneEditing(_ sender: UITextField) {
        if sender.text == "" {
            resetTextFieldWithDefault(sender)
        } else {
            saveNewValueInDefaults(sender)
        }
    }

    @IBAction func doneOnboarding(_ sender: UIBarButtonItem) {
        Defaults.standard.setBool(true, forKey: SettingsKey.OnboardingComplete)
        let ad = UIApplication.shared.del
        ad.loadInterface()
    }

    func setPickerDelegateAndDataSource() {
        picker.delegate = pickerSource
        picker.dataSource = pickerSource
        pickerSource.dateLabel = resetDateLabel
    }

    func setPickerToDefaultRows() {
        picker.selectRow(defaultResetDay, inComponent: 0, animated: false)
        picker.selectRow(defaultResetHour, inComponent: 1, animated: false)
    }

    func setTextFieldsAndSteppersToDefauls() {
        workHoursTextField.workHours = defaultWorkHours
        stepper.workHours = defaultWorkHours
        workRadiusField.workRadius = defaultWorkRadius
    }

    func resetTextFieldWithDefault(_ sender: UITextField) {
        switch sender {
        case let s as WorkHoursTextField: s.workHours = defaultWorkHours
        case let s as WorkRadiusTextField: s.workRadius = defaultWorkRadius
        default: print("Something is wrong!!! Switching on a UITextField with unknown placeholder")
        }
    }

    func saveNewValueInDefaults(_ sender: UITextField) {
        switch sender {
        case let s as WorkHoursTextField:  defaultWorkHours = s.workHours
        case let s as WorkRadiusTextField: defaultWorkRadius = s.workRadius
        default: print("Something is wrong!!! Switching on a UITextField with unknown placeholder")
        }
    }
}
