import UIKit
import MapKit

struct OverlayColor {
    static let Fill   = UIColor(red:0.18, green:0.71, blue:0.73, alpha:0.4)
    static let Stroke = UIColor(red:0.18, green:0.71, blue:0.73, alpha:1)
}

struct Counter {
    static var count = 0
}

struct MapRegionIdentifiers {
    static let work = "WorkRegion"
}

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!

    var regionRadius: Double { return Double(Defaults.standard.integerForKey(SettingsKey.workRadius)) }

    lazy var locationManager: CLLocationManager = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        return appDelegate.locationManager
    }()

    lazy var workManager: WorkManager = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        return appDelegate.workManager
    }()

    var workLocation: CLCircularRegion? {
        if let regions = locationManager.monitoredRegions? as NSSet? {
            if regions.count > 0 {
                for region in regions {
                    let typedRegion = region as CLCircularRegion
                    if typedRegion.identifier == MapRegionIdentifiers.work {
                        return typedRegion
                    }
                }
            }

        }
        return nil
    }

    override func viewDidLoad() {
        Counter.count = 0 //reset the counter so we can zoom in on the user once, per page load
        super.viewDidLoad()

        //draw the current work location if it is not nil
        if let work = workLocation {
            let workOverlay = MKCircle(centerCoordinate: work.center, radius: regionRadius)
            mapView.addOverlay(workOverlay)
        }
    }

    // MARK: - My Geofence
    @IBAction func handleLongPress(sender: UILongPressGestureRecognizer) {

        let location = sender.locationInView(mapView)
        //make coordinated from where the user pressed
        let coordinate = mapView.convertPoint(location, toCoordinateFromView: mapView)

        if sender.state == UIGestureRecognizerState.Began {
            addOverLayAtCoordinate(coordinate)
        } else if sender.state == UIGestureRecognizerState.Ended {
           startMonitoringOneRegionAtCoordinate(coordinate)
           addArrivalIfAtWork()
        }
    }

    func addOverLayAtCoordinate(coord: CLLocationCoordinate2D){ //remove existing overlays
        if let overlays = mapView.overlays {
            let existingOverlays = mapView.overlays
            mapView.removeOverlays(existingOverlays)
        }
        //add a circle over lay where the user pressed
        let circle = MKCircle(centerCoordinate: coord, radius: regionRadius)
        mapView.addOverlay(circle) //make sure to draw this overlay in the delegate
    }

    func startMonitoringOneRegionAtCoordinate(coord: CLLocationCoordinate2D) {
        //current limitation: Only one location may be used!!!
        let currentRegions = locationManager.monitoredRegions as NSSet
        for region in currentRegions {
            locationManager.stopMonitoringForRegion(region as CLRegion)
        }

        //also if setting a new work location, we need to clear the existing work history
        workManager.clearEvents()

        let workRegion = CLCircularRegion(center: coord, radius: regionRadius, identifier: MapRegionIdentifiers.work)
        locationManager.startMonitoringForRegion(workRegion)
    }

    func addArrivalIfAtWork(){
        //if you are currently at work add an arrival right now.
        for region in locationManager.monitoredRegions {
            if region.identifier == MapRegionIdentifiers.work{
                let workregion = region as CLCircularRegion
                if workregion.containsCoordinate(locationManager.location.coordinate) {
                    workManager.addArrival(NSDate())
                }
            }
        }

    }

}

// MARK: - MapViewDelegate
extension MapViewController: MKMapViewDelegate {

    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        //only do this map zooming thing once
        if Counter.count == 0 {
            println("Updated User Location \(Counter.count++)")
            let userCoordinates = userLocation.location.coordinate
            //stoping location updates
            locationManager.stopUpdatingLocation()

            if let overlays = mapView.overlays {

                //zoom the map so it shows the user and the overlays
                if let overlay = overlays.first as? MKCircle {
                    let mapRect = mapRectToFitCoordinate(userCoordinates, andCoordinate: overlay.coordinate)
                    mapView.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40), animated: true)
                }

            } else {
                //zoom the map to the users location
                //not sure how far away from work the person is, so give them a good zoom 2km
                let region = MKCoordinateRegionMakeWithDistance(userCoordinates, 2000, 2000)
                mapView.setRegion(region, animated: true)
            }
        }
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

    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        println("Selected annotation, Setting region on this annotation")
        addOverLayAtCoordinate(view.annotation.coordinate)
        startMonitoringOneRegionAtCoordinate(view.annotation.coordinate)
        addArrivalIfAtWork()
    }

    func mapRectToFitCoordinate(one: CLLocationCoordinate2D, andCoordinate two: CLLocationCoordinate2D) -> MKMapRect {
        let a = MKMapPointForCoordinate(one)
        let b = MKMapPointForCoordinate(two)
        return MKMapRectMake(min(a.x, b.x), min(a.y,b.y), abs(a.x - b.x), abs(a.y-b.y))
    }


}

extension MapViewController: UISearchBarDelegate {

    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        return true
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {

        searchBar.resignFirstResponder()
        if let searchString = searchBar.text {
            if searchString != "" {

                let request = MKLocalSearchRequest()
                request.naturalLanguageQuery = searchBar.text ?? ""
                request.region = mapView.region

                let search = MKLocalSearch(request: request)
                search.startWithCompletionHandler { [unowned self]
                    response, error in
                    if error != nil {
                        //handl error
                        println(error.localizedDescription)
                        return
                    }
                    //We got a response look at the cool map items that we got back!
                    let items = response.mapItems as [MKMapItem]
                    let placemarks = items.map{$0.placemark}
                    self.mapView.showAnnotations(placemarks, animated: true)
                }

            }
        }
    }
    
}
