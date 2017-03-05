import XCTest

import MapKit
@testable import WorkWeek

class MapViewControllerTests: XCTestCase {

    var storyboard: UIStoryboard!
    var mapVC: MapViewController!
    var view: UIView!

    override func setUp() {
        super.setUp()
        storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "MapViewController")
            as? MapViewController else {
                XCTFail("Can't get Map VC") ; return
        }
        mapVC = vc
        view = mapVC.view
    }

    override func tearDown() {
        storyboard = nil
        mapVC = nil
        view = nil
        super.tearDown()
    }

    func testRendererForCircleOverlay() {

        let coord = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        let overlay = MKCircle(center: coord, radius: 100.0)

        let renderer = mapVC.mapView(mapVC.mapView, rendererFor: overlay)
        XCTAssert(renderer is MKCircleRenderer)
    }

    func testRendererForOtherOverlay() {

        var mapPoints =  [MKMapPoint]()
        mapPoints.append(MKMapPoint(x: 0.0, y: 0.0))
        mapPoints.append(MKMapPoint(x: 0.0, y: 1.0))
        mapPoints.append(MKMapPoint(x: 1.0, y: 1.0))
        mapPoints.append(MKMapPoint(x: 1.0, y: 0.0))
        let polygon = MKPolygon(points: &mapPoints, count: mapPoints.count)

        let renderer = mapVC.mapView(mapVC.mapView, rendererFor: polygon)
        XCTAssert(renderer is MKCircleRenderer, "Default renderer is circle")
        XCTAssert(renderer.alpha == 0.0)
    }

}
