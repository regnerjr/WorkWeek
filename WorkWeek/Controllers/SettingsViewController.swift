import UIKit

struct SettingsKey {
    static let hoursInWorkWeek = "hoursInWorkWeekPrefKey"
    static let unpaidLunchTime = "unpaidLunchTimePrefKey"
    static let resetDay        = "resetDayPrefKey"
    static let resetHour       = "resetHourPrefKey"
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

    lazy var intFormatter: NSNumberFormatter = {
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

    @IBOutlet weak var workHoursTextField: UITextField!
    @IBOutlet weak var lunchTimeField: UITextField!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var picker: UIPickerView!

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

    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = pickerSource
        picker.dataSource = pickerSource
        //set up picker based on defaults
        picker.selectRow(defaultResetDay, inComponent: 0, animated: false)
        picker.selectRow(defaultResetHour, inComponent: 1, animated: false)

        //populate fields with data from defaults
        workHoursTextField.text = intFormatter.stringFromNumber(defaultWorkHours)
        lunchTimeField.text = doubleFormatter.stringFromNumber(defaultLunchTime)
        stepper.value = Double(defaultWorkHours)
    }

    override func viewWillDisappear(animated: Bool) {
        //update the pickerDefaults and set up the notification
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
        workHoursTextField.text = intFormatter.stringFromNumber(sender.value)
        defaultWorkHours = Int(sender.value)
    }

    @IBAction func workHoursDoneEditing(sender: UITextField) {
        if sender.text == "" {
            sender.text = intFormatter.stringFromNumber(defaultWorkHours)
        } else {
            //save the new work hours, or default to 40 if could not be read for some reason...?
            defaultWorkHours = Int(intFormatter.numberFromString(sender.text) ?? 40 ) 
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

    @IBAction func screenTapGesture(sender: UITapGestureRecognizer) {
        if workHoursTextField.isFirstResponder() == true {
            workHoursTextField.endEditing(true)
        }else if lunchTimeField.isFirstResponder() {
            lunchTimeField.endEditing(true)
        }
        resignFirstResponder()
    }
}
