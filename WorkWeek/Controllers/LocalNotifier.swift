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
        UIApplication.sharedApplication().scheduleLocalNotification(note)
        NSLog("Setup a Notification %@, with fire date %@", note, note.fireDate!)
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