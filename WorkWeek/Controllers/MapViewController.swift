import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!

    lazy var locationManager:CLLocationManager = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        return appDelegate.locationManager
    }()
  
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("Prepare for segue to: \(segue.destinationViewController)")
    }

    // MARK: - My Geofence
    
    //locationmanager.startMonitoringRegion()
    @IBAction func setWorkLocation(sender: AnyObject) {
        if let managerCenter = locationManager.location?.coordinate {

            let workRegion = CLCircularRegion(center: managerCenter, radius: 150.0, identifier: "WorkRegion")
            println("Setting workRegion: \(workRegion)")
            println("Regions \(locationManager.monitoredRegions)")

            //current limitation: Only one location may be used!!!
            let currentRegions = locationManager.monitoredRegions as NSSet
            for region in currentRegions {
                locationManager.stopMonitoringForRegion(region as CLRegion)
            }

            //also if setting a new work location, we need to clear the existing work history
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            appDelegate.workManager.clearEvents()

            locationManager.startMonitoringForRegion(workRegion)

            //add a thing to the map to show the new region
            let region = MKCoordinateRegionMakeWithDistance(workRegion.center, 150.0, 150.0)
            mapView.setRegion(region, animated: true)
            
            //currently in order to start monitoring you need to be at work so add an arrival
            let workManager: WorkManager = {
                let ad = UIApplication.sharedApplication().delegate as AppDelegate
                return ad.workManager
            }()
            workManager.addArrival(NSDate())
        } else {
            println("Could not get location")
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}

// MARK: - MapViewDelegate

extension MapViewController: MKMapViewDelegate {

    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        println("MapViewDelegate: didUpdateUserLocation")
        //zoom the map to the users location
        let coords = userLocation.location.coordinate
        let region = MKCoordinateRegion(center: coords, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)

        //once we have the users location on the map, stop looking or location updates
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.locationManager.stopUpdatingLocation() //better for user battery
    }

}