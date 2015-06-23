import UIKit

public class LocalNotifier {

    public func setupNotification(hoursWorkedSoFarThisWeek: Double, hoursInFullWorkWeek: Int){

        let note = UILocalNotification()
        note.fireDate = calculateFireDate(hoursInFullWorkWeek, hoursWorkedSofar: hoursWorkedSoFarThisWeek)
        note.alertBody = "Your Work Week is Over!"
        if #available(iOS 8.2, *) {
            note.alertTitle = "Your Work Week is Over!"
        } else {
        }
        note.hasAction = false
        note.repeatInterval = []
        note.applicationIconBadgeNumber = Defaults.standard.integerForKey(.hoursInWorkWeek)
        note.soundName = UILocalNotificationDefaultSoundName

        // Since this is our only notification we can just clear all of them and schedule this new one
        cancelAllNotifications()
        UIApplication.sharedApplication().scheduledLocalNotifications = nil
        UIApplication.sharedApplication().scheduleLocalNotification(note)
        NSLog("Notification %@", note)
    }

    public func cancelAllNotifications(){
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }

    func calculateFireDate(hoursInFullWeek:Int, hoursWorkedSofar: Double) -> NSDate? {

        if hoursWorkedSofar < Double(hoursInFullWeek) {
            let hoursLeft = Double(hoursInFullWeek) - hoursWorkedSofar //hours left will be of the form 5.2 hours
            let secondsLeft = convertDecimalHoursToSeconds(hoursLeft)
            return NSDate(timeIntervalSinceNow: secondsLeft)
        } else {
            return nil //fire the notification now
        }
    }

}

func convertDecimalHoursToSeconds(hours: Double) -> Double{

    let secondsPerMinute = 60.0
    let minutesPerHour = 60.0
    return hours * minutesPerHour * secondsPerMinute
}
