import UIKit

open class LocalNotifier {

    open func setupNotification(_ hoursWorkedSoFarThisWeek: Double, hoursInFullWorkWeek: Int) {

        let note = UILocalNotification()
        note.fireDate = calculateFireDate(hoursInFullWorkWeek,
                                          hoursWorkedSofar: hoursWorkedSoFarThisWeek)
        note.alertBody = "Your Work Week is Over!"
        note.alertTitle = "Your Work Week is Over!"
        note.hasAction = false
        note.repeatInterval = []
        note.applicationIconBadgeNumber = Defaults.standard.integerForKey(.hoursInWorkWeek)
        note.soundName = UILocalNotificationDefaultSoundName

        // Since this is our only notification we can just clear all of them and
        // schedule this new one
        cancelAllNotifications()
        UIApplication.shared.scheduledLocalNotifications = nil
        UIApplication.shared.scheduleLocalNotification(note)
        NSLog("Notification %@", note)
    }

    open func cancelAllNotifications() {
        UIApplication.shared.cancelAllLocalNotifications()
    }

    func calculateFireDate(_ hoursInFullWeek: Int, hoursWorkedSofar: Double) -> Date? {
        if hoursWorkedSofar < Double(hoursInFullWeek) {
            //hours left will be of the form 5.2 hours
            let hoursLeft = Double(hoursInFullWeek) - hoursWorkedSofar
            let secondsLeft = convertDecimalHoursToSeconds(hoursLeft)
            return Date(timeIntervalSinceNow: secondsLeft)
        } else {
            return nil //fire the notification now
        }
    }
}

func convertDecimalHoursToSeconds(_ hours: Double) -> Double {
    let secondsPerMinute = 60.0
    let minutesPerHour = 60.0
    return hours * minutesPerHour * secondsPerMinute
}
