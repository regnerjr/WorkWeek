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
    @IBAction func handleLongPress(sender: UILongPressGestureRecognizer) {

        let location = sender.locationInView(mapView)
        //make coordinated from where the user pressed
        let coordinate = mapView.convertPoint(location, toCoordinateFromView: mapView)

        if sender.state == UIGestureRecognizerState.Began {

            //remove existing overlays
            if let overlays = mapView.overlays {
                let existingOverlays = mapView.overlays
                mapView.removeOverlays(existingOverlays)
            }
            //add a circle over lay where the user pressed
            let circle = MKCircle(centerCoordinate: coordinate, radius: RegionRadius.value)
            mapView.addOverlay(circle) //make sure to draw this overlay in the delegate

        } else if sender.state == UIGestureRecognizerState.Ended {

            //current limitation: Only one location may be used!!!
            let currentRegions = locationManager.monitoredRegions as NSSet
            for region in currentRegions {
                locationManager.stopMonitoringForRegion(region as CLRegion)
            }

            //also if setting a new work location, we need to clear the existing work history
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            appDelegate.workManager.clearEvents()

            let workRegion = CLCircularRegion(center: coordinate, radius: RegionRadius.value, identifier: MapRegionIdentifiers.work)
            locationManager.startMonitoringForRegion(workRegion)

            //if you are currently at work add an arrival right now.
            let ad = UIApplication.sharedApplication().delegate as AppDelegate
            if workRegion.containsCoordinate(ad.locationManager.location.coordinate) {
                ad.workManager.addArrival(NSDate())
            }
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


    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        //only one overlay so dont bother to check it just return a renderer
        if overlay is MKCircle{
            let renderer = MKCircleRenderer(circle: overlay as MKCircle)
            renderer.fillColor = OverlayColor.Fill
            renderer.strokeColor = OverlayColor.Stroke
            renderer.lineWidth = 5
            return renderer
        } else {
            return MKOverlayRenderer(overlay: overlay) //just return a default unconfigured renderer
        }
    }


}