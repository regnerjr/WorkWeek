import UIKit

public class LocalNotifier {

    public class func setupNotification(soFar: Double, total: Int){
        //schedule a notification to fire when 40 hours have been worked.
        //assume that the person will stay at work the rest of the week

        //how far in the future do we need to schedule the notification
        let note = UILocalNotification()

        // if we worked more than our 40 then notify once
        if soFar < Double(total) {
            let hoursLeft = Double(total) - soFar //hours left will be of the form 5.2 hours
            let secondsLeft = convertDecimalHoursToSeconds(hoursLeft)
            note.fireDate = NSDate(timeIntervalSinceNow: secondsLeft)
        } else {
            note.fireDate = nil //fire the notification now
        }
        note.alertTitle = "Your Work Week is Over!"
        note.alertBody = "Your Work Week is Over!"
        note.hasAction = false
        note.repeatInterval = .allZeros
        note.applicationIconBadgeNumber = Defaults.standard.integerForKey(.hoursInWorkWeek)
        note.soundName = UILocalNotificationDefaultSoundName

        // Since this is our only notification we can just clear all of them and schedule this new one
        UIApplication.sharedApplication().scheduledLocalNotifications = nil

        UIApplication.sharedApplication().scheduleLocalNotification(note)
        NSLog("Setup a Notification %@", note)
    }

    public class func cancelAllNotifications(){
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
}

func convertDecimalHoursToSeconds(hours: Double) -> Double{

    let secondsPerMinute = 60.0
    let minutesPerHour = 60.0
    return hours * minutesPerHour * secondsPerMinute
}