//
//  OBLocationViewController.swift
//  WorkWeek
//
//  Created by John Regner on 6/23/15.
//  Copyright © 2015 WigglingScholars. All rights reserved.
//

import UIKit
import CoreLocation

class OBLocationViewController: UIViewController {

    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var grantAccessButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    /// Returns a bool stating if we have the proper authorization status or not
    var locationAccess: Bool {
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways: return true
        case _: return false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {

        if !CLLocationManager.locationServicesEnabled() {
            //show an alert
            //offer button to Settings.
            let alert = UIAlertController(title: "Error", message: "Location Services Need to Be Enabled\nYou can enable access in\nSettings->Privacy->Location Services", preferredStyle: UIAlertControllerStyle.ActionSheet)
            let goToSettings = UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: { action in
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            })
            alert.addAction(goToSettings)
            self.presentViewController(alert, animated: true, completion: nil)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func grantAccess(sender: UIButton) {
        // Pop up the Location Manager request for Location Access
        let ad = UIApplication.sharedApplication().delegate as! AppDelegate
        ad.locationManager = LocationManager()
        //perform segue to next view
        performSegueWithIdentifier("OnboardingMapShow", sender: nil)
    }

    @IBAction func cancel(sender: UIButton) {
        //show popup with more details about how the app will not work without location services.
            let alert = UIAlertController(title: "Sorry", message: "Work Week will not work without access to your phone's location.", preferredStyle: UIAlertControllerStyle.Alert)
            let OK = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(OK)
            self.presentViewController(alert, animated: true, completion: nil)
    }

}
