import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var workHoursTextField: UITextField!
    @IBOutlet weak var lunchTimeField: UITextField!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var workRadius: UITextField!

    let pickerSource = DayTimePicker()

    var defaultWorkHours: Int {
        get { return NSUserDefaults.standardUserDefaults().integerForKey(SettingsKey.hoursInWorkWeek) }
        set { NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: SettingsKey.hoursInWorkWeek) }
    }
    var defaultLunchTime: Double {
        get {return NSUserDefaults.standardUserDefaults().doubleForKey(SettingsKey.unpaidLunchTime) }
        set { NSUserDefaults.standardUserDefaults().setDouble(newValue, forKey: SettingsKey.unpaidLunchTime) }
    }
    var defaultResetDay: Int {
        get { return NSUserDefaults.standardUserDefaults().integerForKey(SettingsKey.resetDay) }
        set { NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: SettingsKey.resetDay) }
    }
    var defaultResetHour: Int {
        get { return NSUserDefaults.standardUserDefaults().integerForKey(SettingsKey.resetHour) }
        set { NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey:SettingsKey.resetHour) }
    }
    var defaultWorkRadius: Int {
        get{ return NSUserDefaults.standardUserDefaults().integerForKey(SettingsKey.workRadius) }
        set{ NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: SettingsKey.workRadius) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = pickerSource
        picker.dataSource = pickerSource
        //set up picker based on defaults
        picker.selectRow(defaultResetDay, inComponent: 0, animated: false)
        picker.selectRow(defaultResetHour, inComponent: 1, animated: false)

        //populate fields with data from defaults
        workHoursTextField.text = Formatter.workHours.stringFromNumber(defaultWorkHours)
        lunchTimeField.text = Formatter.double.stringFromNumber(defaultLunchTime)
        stepper.value = Double(defaultWorkHours)
        workRadius.text = Formatter.workRadius.stringFromNumber(defaultWorkRadius)
    }

    override func viewWillDisappear(animated: Bool) {
        //update the pickerDefaults and set up the notification
        //could handle these in the delegate, but it is easier here, and the logic is small
        defaultResetDay = picker.selectedRowInComponent(0)
        defaultResetHour = picker.selectedRowInComponent(1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        println("Received MemoryWarning")
    }

    @IBAction func launchSystemSettings(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }

    @IBAction func stepWorkHours(sender: UIStepper) {
        //change the value stored in the label
        workHoursTextField.text = Formatter.workHours.stringFromNumber(sender.value)
        defaultWorkHours = Int(sender.value)
    }

    @IBAction func workHoursDoneEditing(sender: UITextField) {
        if sender.text == "" {
            sender.text = Formatter.workHours.stringFromNumber(defaultWorkHours)
        } else {
            //save the new work hours, or default to 40 if could not be read for some reason...?
            defaultWorkHours = Int(Formatter.workHours.numberFromString(sender.text) ?? 40 )
        }
    }

    @IBAction func lunchFieldDoneEditing(sender: UITextField) {
        if sender.text == "" {
            sender.text = Formatter.double.stringFromNumber(defaultLunchTime)
        } else {
            //save new lunch time or default
            defaultLunchTime = Double(Formatter.double.numberFromString(sender.text) ?? 0.5 )
        }
    }

    @IBAction func workRadiusDoneEditing(sender: UITextField) {
        if sender.text == "" {
            sender.text = Formatter.workRadius.stringFromNumber(defaultWorkRadius)
        } else {
            defaultWorkRadius = Int(Formatter.workRadius.numberFromString(sender.text) ?? 200)
        }
    }

    @IBAction func screenTapGesture(sender: UITapGestureRecognizer) {
        if workHoursTextField.isFirstResponder() {
            workHoursTextField.endEditing(true)
        }else if lunchTimeField.isFirstResponder() {
            lunchTimeField.endEditing(true)
        } else if workRadius.isFirstResponder() {
            workRadius.endEditing(true)
        }
        resignFirstResponder()
    }
}
