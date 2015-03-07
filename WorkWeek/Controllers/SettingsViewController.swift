import UIKit

struct SettingsKey {
    static let hoursInWorkWeek = "hoursInWorkWeekPrefKey"
    static let unpaidLunchTime = "unpaidLunchTimePrefKey"
    static let resetDay        = "resetDayPrefKey"
    static let resetHour       = "resetHourPrefKey"
    static let workRadius      = "workRadiusPrefKey"
}

class SettingsViewController: UIViewController {

    lazy var doubleFormatter: NSNumberFormatter = {
        let doubleFormatter = NSNumberFormatter()
        doubleFormatter.numberStyle = .DecimalStyle
        doubleFormatter.minimum = 0.1
        doubleFormatter.maximum = 9.9
        doubleFormatter.minimumIntegerDigits = 1
        doubleFormatter.maximumIntegerDigits = 1
        doubleFormatter.minimumFractionDigits = 1
        doubleFormatter.maximumFractionDigits = 1
        doubleFormatter.roundingIncrement = 0.1
        doubleFormatter.roundingMode = NSNumberFormatterRoundingMode.RoundUp
        return doubleFormatter
    }()

    lazy var workHoursFormatter: NSNumberFormatter = {
        let intFormatter = NSNumberFormatter()
        intFormatter.numberStyle = NSNumberFormatterStyle.NoStyle
        intFormatter.minimum = 1
        intFormatter.maximum = 99
        intFormatter.minimumIntegerDigits = 1
        intFormatter.maximumIntegerDigits = 2
        intFormatter.minimumFractionDigits = 0
        intFormatter.maximumFractionDigits = 0
        intFormatter.roundingIncrement = 1
        intFormatter.roundingMode = NSNumberFormatterRoundingMode.RoundUp
        return intFormatter
    }()

    lazy var workRadiusFormatter: NSNumberFormatter = {
        let radiusFormatter = NSNumberFormatter()
        radiusFormatter.numberStyle = NSNumberFormatterStyle.NoStyle
        radiusFormatter.minimum = 50 //allow workRadius to be between 50 and 999 meters
        radiusFormatter.maximum = 999
        radiusFormatter.minimumIntegerDigits = 2
        radiusFormatter.maximumIntegerDigits = 3
        radiusFormatter.minimumFractionDigits = 0
        radiusFormatter.maximumFractionDigits = 0
        radiusFormatter.roundingIncrement = 1
        radiusFormatter.roundingMode = NSNumberFormatterRoundingMode.RoundUp
        return radiusFormatter
    }()

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
    var defautlWorkRadius: Int {
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
        workHoursTextField.text = workHoursFormatter.stringFromNumber(defaultWorkHours)
        lunchTimeField.text = doubleFormatter.stringFromNumber(defaultLunchTime)
        stepper.value = Double(defaultWorkHours)
        workRadius.text = workRadiusFormatter.stringFromNumber(defautlWorkRadius)
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
        workHoursTextField.text = workHoursFormatter.stringFromNumber(sender.value)
        defaultWorkHours = Int(sender.value)
    }

    @IBAction func workHoursDoneEditing(sender: UITextField) {
        if sender.text == "" {
            sender.text = workHoursFormatter.stringFromNumber(defaultWorkHours)
        } else {
            //save the new work hours, or default to 40 if could not be read for some reason...?
            defaultWorkHours = Int(workHoursFormatter.numberFromString(sender.text) ?? 40 ) 
        }
    }

    @IBAction func lunchFieldDoneEditing(sender: UITextField) {
        if sender.text == "" {
            sender.text = doubleFormatter.stringFromNumber(defaultLunchTime)
        } else {
            //save new lunch time or default
            defaultLunchTime = Double(doubleFormatter.numberFromString(sender.text) ?? 0.5 )
        }
    }
    @IBAction func workRadiusDoneEditing(sender: UITextField) {
        if sender.text == "" {
            sender.text = workRadiusFormatter.stringFromNumber(defautlWorkRadius)
        } else {
            defautlWorkRadius = Int(workRadiusFormatter.numberFromString(sender.text) ?? 200)
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
