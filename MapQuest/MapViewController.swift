

import UIKit
import MapKit
import WebKit
class MapViewController: UIViewController {
  // MARK: - IBOutlets
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var heartsLabel: UILabel!

  @IBOutlet weak var WebView: WKWebView!
  
  // MARK: - Properties
  // swiftlint:disable implicitly_unwrapped_optional
  var tileRenderer: MKTileOverlayRenderer!
  var shimmerRenderer: ShimmerRenderer!
  // swiftlint:enable implicitly_unwrapped_optional

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    setupTileRenderer()
    WebView.scrollView.isScrollEnabled = false;
    let urls = URL(string: "http://192.168.56.1:6006/")!;
    WebView.load(URLRequest(url: urls))
    let initialRegion = MKCoordinateRegion(
      center: CLLocationCoordinate2D(latitude: 0, longitude: -5),
      span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3))

    mapView.cameraZoomRange = MKMapView.CameraZoomRange(
      minCenterCoordinateDistance: 10000000,
      maxCenterCoordinateDistance: 10000000000)
    mapView.cameraBoundary = MKMapView.CameraBoundary(coordinateRegion: initialRegion)

    mapView.region = initialRegion
    mapView.showsUserLocation = true
    mapView.showsCompass = true
    mapView.setUserTrackingMode(.followWithHeading, animated: true)



    mapView.delegate = self
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }

  private func setupTileRenderer() {
    let overlay = AdventureMapOverlay()

    overlay.canReplaceMapContent = true
    mapView.addOverlay(overlay, level: .aboveLabels)
    tileRenderer = MKTileOverlayRenderer(tileOverlay: overlay)

    overlay.minimumZ = 3
    overlay.maximumZ = 4
  }

  @objc func gameUpdated(notification: Notification) {
  }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
  // Add delegates here
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if overlay is AdventureMapOverlay {
      return tileRenderer
    } else {
      return shimmerRenderer
    }
  }

  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    switch annotation {
    case let user as MKUserLocation:
      if let existingView = mapView.dequeueReusableAnnotationView(withIdentifier: "user") {
        return existingView
      } else {
        let view = MKAnnotationView(annotation: user, reuseIdentifier: "user")
        // swiftlint:disable:next discouraged_object_literal
        view.image = #imageLiteral(resourceName: "user")
        return view
      }
//    case let warp as WarpZone:
//      if let existingView = mapView.dequeueReusableAnnotationView(
//        withIdentifier: WarpAnnotationView.identifier) {
//        existingView.annotation = annotation
//        return existingView
//      } else {
//        return WarpAnnotationView(annotation: warp, reuseIdentifier: WarpAnnotationView.identifier)
//      }
    default:
      return nil
    }
  }
}

// MARK: - Game UI

