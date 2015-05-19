import Foundation

struct NotificationCenter {
    static var arrival: String {
        return "ArrivalNotificationKey"
    }
    static var departure: String {
        return "DepartureNotificationKey"
    }
}

extension WorkManager {
    func observeNotifications(center: NSNotificationCenter = NSNotificationCenter.defaultCenter()){
        center.addObserver(self, selector: Selector("addArrival:"), name: NotificationCenter.arrival, object: nil)
        center.addObserver(self, selector: Selector("addDeparture:"), name: NotificationCenter.departure, object: nil)
    }
    func stopObservingNotifications(center: NSNotificationCenter = NSNotificationCenter.defaultCenter()){
        center.removeObserver(self)
    }
}