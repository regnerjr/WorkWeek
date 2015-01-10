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
    }
}

// MARK: - UISearchBarExtension

extension MapViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        println("Search Button was clicked: \(searchBar.text)")
        searchBar.resignFirstResponder()
    }
}