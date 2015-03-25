import UIKit
import XCTest

import WorkWeek

class LocalNotifierTest: XCTestCase {


    func testScheduleAndCancelNotification() {
        let types = UIUserNotificationType.Badge | UIUserNotificationType.Sound | UIUserNotificationType.Alert
        let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)

        LocalNotifier.setupNotification(0.5, total: 1)

        let notes = UIApplication.sharedApplication().scheduledLocalNotifications as [UILocalNotification]?

        XCTAssert(notes?.count == 1, "At least one notification is scheduled. \(notes?.count)")
        notes?.map{ println($0.alertTitle) }
        LocalNotifier.cancelAllNotifications()

        let notes2 = UIApplication.sharedApplication().scheduledLocalNotifications as [UILocalNotification]?

        XCTAssert(notes2?.count == 0, "All notifications are cleared. Count: \(notes2?.count)")
    }
}
