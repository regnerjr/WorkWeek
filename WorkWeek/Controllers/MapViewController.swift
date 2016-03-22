import UIKit
import MapKit

//This global var is to ensure that the map view is only zoomed on time on initial load.
struct MapViewState {
    static var hasBeenZoomed = false
}

public struct MapRegionIdentifiers {
    public static let work = "WorkRegion"
}

public class MapViewController: UIViewController {

    @IBOutlet public weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!

    var regionRadius: Double { return Double(Defaults.standard.integerForKey(.WorkRadius)) }

    var locationManager: LocationManager {
        let appDelegate = UIApplication.sharedApplication().del
        return appDelegate.locationManager
    }

    lazy var workManager: WorkManager = {
        let appDelegate = UIApplication.sharedApplication().del
        return appDelegate.workManager
    }()

    var workLocations: [CLCircularRegion]? {
        return locationManager.monitoredRegions?.flatMap { $0 as? CLCircularRegion }
    }

    override public func viewDidLoad() {
        MapViewState.hasBeenZoomed = false
        //reset the state so we can zoom in on the user once, per page load
        super.viewDidLoad()
        drawWorkLocations(workLocations)
    }

    public override func prefersStatusBarHidden() -> Bool {
        return true
    }

    @IBAction func handleLongPress(sender: UILongPressGestureRecognizer) {
        let location = sender.locationInView(mapView)
        //make coordinated from where the user pressed
        let coordinate = mapView.convertPoint(location, toCoordinateFromView: mapView)

        if sender.state == .Began {
            addOverLayAtCoordinate(coordinate)
        } else if sender.state == .Ended {
            locationManager.startMonitoringRegionAtCoordinate(coordinate, withRadius: regionRadius)
            if locationManager.atWork() {
                workManager.addArrival()
            } else {
                workManager.addDeparture()
            }
        }
    }

    func addOverLayAtCoordinate(coord: CLLocationCoordinate2D) {
        //remove existing overlays
        let existingOverlays = mapView.overlays
        mapView.removeOverlays(existingOverlays)
        //add a circle over lay where the user pressed
        let circle = MKCircle(centerCoordinate: coord, radius: regionRadius)
        mapView.addOverlay(circle)
    }

    func drawWorkLocations( workLocations: [CLCircularRegion]?) {
        //draw the current work locations if it is not nil
        workLocations?.map { location in
            return MKCircle(centerCoordinate: location.center, radius: self.regionRadius)
        }.forEach(mapView.addOverlay)
    }

}

extension MapViewController: MKMapViewDelegate {

    public func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        //only do this map zooming thing once
        if MapViewState.hasBeenZoomed == false {
            MapViewState.hasBeenZoomed = true
            if let userCoordinates = userLocation.location?.coordinate {
                //stoping location updates
                locationManager.manager.stopUpdatingLocation()

                if mapView.overlays.count > 0 {

                    //zoom the map so it shows the user and the overlays
                    if let overlay = mapView.overlays.first as? MKCircle {
                        let mapRect = mapRectToFitCoordinate(userCoordinates,
                                                             andCoordinate: overlay.coordinate)
                        let insets = UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40)
                        mapView.setVisibleMapRect(mapRect,
                                                  edgePadding: insets, animated: true)
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

    public func mapView(mapView: MKMapView,
                        rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        return (overlay as? MKCircle)?.defaultRenderer ?? MKCircle.clearRenderer(overlay.coordinate)
    }

    public func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        addOverLayAtCoordinate(view.annotation!.coordinate)
        locationManager.startMonitoringRegionAtCoordinate(view.annotation!.coordinate,
                                                          withRadius: regionRadius)
        workManager.addArrivalIfAtWork(locationManager)
    }

    func mapRectToFitCoordinate(one: CLLocationCoordinate2D,
                                andCoordinate two: CLLocationCoordinate2D) -> MKMapRect {
        let a = MKMapPointForCoordinate(one)
        let b = MKMapPointForCoordinate(two)
        return MKMapRectMake(min(a.x, b.x), min(a.y, b.y), abs(a.x - b.x), abs(a.y-b.y))
    }

}

extension MKCircle {
    var defaultRenderer: MKCircleRenderer {
        let renderer = MKCircleRenderer(circle: self)
        renderer.fillColor = OverlayColor.Fill
        renderer.strokeColor = OverlayColor.Stroke
        renderer.lineWidth = 5
        renderer.alpha = 0.75
        return renderer
    }
    static func clearRenderer(center: CLLocationCoordinate2D) -> MKCircleRenderer {
        let renderer = MKCircleRenderer(circle: MKCircle(centerCoordinate: center, radius: 100))
        renderer.alpha = 0.0
        return renderer
    }
}

extension MapViewController: UISearchBarDelegate {

    public func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        return true
    }

    public func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        handleSearch(searchBar.text)
    }

    func handleSearch(string: String?) {
        if let searchString = searchBar.text where searchString != "" {
            let request = configureRequest(searchString)

            let search = MKLocalSearch(request: request)
            search.startWithCompletionHandler { response, error in
                if error != nil {
                    //handle error
                    print(error!.localizedDescription)
                    return
                }
                //We got a response look at the cool map items that we got back!
                let items = response!.mapItems
                let placemarks = items.map {$0.placemark}
                self.mapView.showAnnotations(placemarks, animated: true)
            }

        }
    }

    func configureRequest(searchText: String) -> MKLocalSearchRequest {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchText
        request.region = mapView.region
        return request
    }

}
