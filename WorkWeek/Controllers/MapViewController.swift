import UIKit
import MapKit

//This global var is to ensure that the map view is only zoomed on time on initial load.
struct MapViewState {
    static var hasBeenZoomed = false
}

public struct MapRegionIdentifiers {
    public static let work = "WorkRegion"
}

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!

    var regionRadius: Double { return Double(Defaults.standard.integerForKey(.workRadius)) }

    var locationManager: LocationManager {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if appDelegate.locationManager == nil {
            appDelegate.locationManager = LocationManager()
        }
        return appDelegate.locationManager!
    }

    lazy var workManager: WorkManager = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.workManager
    }()

    var workLocations: [CLCircularRegion]? {
        if let regions = locationManager.monitoredRegions {
            if regions.count > 0 {
                return map(regions){ $0 as! CLCircularRegion }
            }

        }
        return nil
    }

    override func viewDidLoad() {
        MapViewState.hasBeenZoomed = false //reset the state so we can zoom in on the user once, per page load
        super.viewDidLoad()

        //draw the current work locations if it is not nil
        if let locations = workLocations {
            map(locations){ location -> Void in
                let workOverlay = MKCircle(centerCoordinate: location.center, radius: self.regionRadius)
                self.mapView.addOverlay(workOverlay)
            }
        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    // MARK: - My Geofence
    @IBAction func handleLongPress(sender: UILongPressGestureRecognizer) {
        let location = sender.locationInView(mapView)
        //make coordinated from where the user pressed
        let coordinate = mapView.convertPoint(location, toCoordinateFromView: mapView)

        if sender.state == .Began {
            addOverLayAtCoordinate(coordinate)
        } else if sender.state == .Ended {
            locationManager.startMonitoringRegionAtCoordinate(coordinate, withRadius: regionRadius)
            if locationManager.atWork() { workManager.addArrival() }
            else { workManager.addDeparture() }
        }
    }

    func addOverLayAtCoordinate(coord: CLLocationCoordinate2D){
        //remove existing overlays
        if let overlays = mapView.overlays {
            let existingOverlays = mapView.overlays
            mapView.removeOverlays(existingOverlays)
        }
        //add a circle over lay where the user pressed
        let circle = MKCircle(centerCoordinate: coord, radius: regionRadius)
        mapView.addOverlay(circle) //make sure to draw this overlay in the delegate
    }

}


// MARK: - MapViewDelegate
extension MapViewController: MKMapViewDelegate {

    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        //only do this map zooming thing once
        if MapViewState.hasBeenZoomed == false {
            MapViewState.hasBeenZoomed = true
            if let userCoordinates = userLocation.location?.coordinate {
                //stoping location updates
                locationManager.manager.stopUpdatingLocation()

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
    }

    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        //only one overlay so dont bother to check it just return a renderer
        if overlay is MKCircle{
            let renderer = MKCircleRenderer(circle: overlay as! MKCircle)
            renderer.fillColor = OverlayColor.Fill
            renderer.strokeColor = OverlayColor.Stroke
            renderer.lineWidth = 5
            return renderer
        } else {
            return MKOverlayRenderer(overlay: overlay) //just return a default unconfigured renderer
        }
    }

    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        addOverLayAtCoordinate(view.annotation.coordinate)
        locationManager.startMonitoringRegionAtCoordinate(view.annotation.coordinate, withRadius: regionRadius)
        workManager.addArrivalIfAtWork(locationManager)
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
        if let searchString = searchBar.text where searchString != ""{
//            if searchString != "" {

            let request = MKLocalSearchRequest()
            request.naturalLanguageQuery = searchBar.text ?? ""
            request.region = mapView.region

            let search = MKLocalSearch(request: request)
            search.startWithCompletionHandler { [unowned self]
                response, error in
                if error != nil {
                    //handle error
                    println(error.localizedDescription)
                    return
                }
                //We got a response look at the cool map items that we got back!
                let items = response.mapItems as! [MKMapItem]
                let placemarks = items.map{$0.placemark}
                self.mapView.showAnnotations(placemarks, animated: true)
            }

//            }
        }
    }
    
}
