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
        mapView.showsUserLocation = true
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
            locationManager.startMonitoringForRegion(workRegion)

            //add a thing to the map to show the new region
            let region: MKCoordinateRegion = MKCoordinateRegion(center: workRegion.center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
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
    }

}

// MARK: - MapViewDelegate

extension MapViewController: MKMapViewDelegate {

    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        println("MapViewDelegate: didUpdateUserLocation")
        //zoom the map to the users location
        let coords = userLocation.location.coordinate
        let region = MKCoordinateRegion(center: coords, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        mapView.setRegion(region, animated: true)
    }

}