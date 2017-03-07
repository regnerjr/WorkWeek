import UIKit
import MapKit
import Prelude

//This global var is to ensure that the map view is only zoomed on time on initial load.
struct MapViewState {
    static var hasBeenZoomed = false
}

public struct MapRegionIdentifiers {
    public static let work = "WorkRegion"
}

open class MapViewController: UIViewController {

    @IBOutlet open weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!

    var regionRadius: Double { return Double(Defaults.standard.integerForKey(.WorkRadius)) }

    var locationManager: LocationManager {
        let appDelegate = UIApplication.shared.del
        return appDelegate.locationManager
    }

    lazy var workManager: WorkManager = {
        let appDelegate = UIApplication.shared.del
        return appDelegate.workManager
    }()

    var workLocations: [CLCircularRegion]? {
        return locationManager.monitoredRegions?.flatMap { $0 as? CLCircularRegion }
    }

    override open func viewDidLoad() {
        MapViewState.hasBeenZoomed = false
        //reset the state so we can zoom in on the user once, per page load
        super.viewDidLoad()
        drawWorkLocations(workLocations)
    }

    open override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: mapView)
        //make coordinated from where the user pressed
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)

        if sender.state == .began {
            addOverLayAtCoordinate(coordinate)
        } else if sender.state == .ended {
            locationManager.startMonitoringRegionAtCoordinate(coordinate, withRadius: regionRadius)
            if locationManager.atWork() {
                workManager.addArrival()
            } else {
                workManager.addDeparture()
            }
        }
    }

    func addOverLayAtCoordinate(_ coord: CLLocationCoordinate2D) {
        //remove existing overlays
        mapView.overlays |> mapView.removeOverlays
        //add a circle over lay where the user pressed
        let circle = MKCircle(center: coord, radius: regionRadius)
        mapView.add(circle)
    }

    func drawWorkLocations( _ workLocations: [CLCircularRegion]?) {
        //draw the current work locations if it is not nil
        workLocations?.map { location in
            return MKCircle(center: location.center, radius: self.regionRadius)
        }.forEach(mapView.add(_:))
    }

}

extension MapViewController: MKMapViewDelegate {

    public func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
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

    public func mapView(_ mapView: MKMapView,
                        rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return (overlay as? MKCircle)?.defaultRenderer ?? MKCircle.clearRenderer(overlay.coordinate)
    }

    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        addOverLayAtCoordinate(view.annotation!.coordinate)
        locationManager.startMonitoringRegionAtCoordinate(view.annotation!.coordinate,
                                                          withRadius: regionRadius)
        workManager.addArrivalIfAtWork(locationManager)
    }

    func mapRectToFitCoordinate(_ one: CLLocationCoordinate2D,
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
    static func clearRenderer(_ center: CLLocationCoordinate2D) -> MKCircleRenderer {
        let renderer = MKCircleRenderer(circle: MKCircle(center: center, radius: 100))
        renderer.alpha = 0.0
        return renderer
    }
}

extension MapViewController: UISearchBarDelegate {

    public func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        handleSearch(searchBar.text)
    }

    func handleSearch(_ string: String?) {
        if let searchString = searchBar.text, searchString != "" {
            let request = configureRequest(searchString)

            let search = MKLocalSearch(request: request)
            search.start { response, error in
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

    func configureRequest(_ searchText: String) -> MKLocalSearchRequest {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchText
        request.region = mapView.region
        return request
    }

}
