

import UIKit
import MapKit
import WebKit
class MapViewController: UIViewController {
  // MARK: - IBOutlets
  func post(){
    let url = URL(string: "https://jsonplaceholder.typicode.com/todos")
    guard let requestUrl = url else { fatalError() }
    // Prepare URL Request Object
    var request = URLRequest(url: requestUrl)
    request.httpMethod = "POST"
     
    // HTTP Request Parameters which will be sent in HTTP Request Body
    let postString = "userId=300&title=My urgent task&completed=false";
    // Set HTTP Request Body
    request.httpBody = postString.data(using: String.Encoding.utf8);
    // Perform HTTP Request
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                return
            }
     
            // Convert HTTP Response Data to a String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data string:\n \(dataString)")
            }
    }
    task.resume()
  }
  var previous: MKAnnotation?
  
  var speed: Double = 100000

  var warps: WarpZone =  WarpZone(latitude: 45.76518, longitude: -73.990)
  
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var heartsLabel: UILabel!
  

  @IBAction func addPin(_ sender: UILongPressGestureRecognizer) {
    if(!(previous == nil)){
      self.mapView.removeAnnotation(previous as! MKAnnotation)
    }
    let location = sender.location(in: self.mapView) //Tells where the mapView is being clicked
    let locCoord = self.mapView.convert(location, toCoordinateFrom: self.mapView)
    print(locCoord)
    let annotation = MKPointAnnotation()
    previous = annotation
    annotation.coordinate = locCoord
    annotation.title = "Drone Destination"
    annotation.subtitle = "Location of Destination"
    self.mapView.addAnnotation(annotation)
    
    updatePos(longitude: annotation.coordinate.longitude, latitude: annotation.coordinate.latitude)
   
    
    
  }
  
  func updatePos(longitude: Double, latitude: Double){
  post()
   
    let deltax = latitude - 10 - warps.coordinate.latitude
    let deltay = longitude - warps.coordinate.longitude
    print(latitude)
    print(longitude)
    print(warps.coordinate.latitude)
    print(warps.coordinate.longitude)

    UIView.animate(withDuration: 10){
      self.warps.coordinate.latitude += deltax
      self.warps.coordinate.longitude += deltay
    }
    

  
  }
  @IBOutlet weak var WebView: WKWebView!
  
  
  // MARK: - Properties
  // swiftlint:disable implicitly_unwrapped_optional
  var tileRenderer: MKTileOverlayRenderer!
  var shimmerRenderer: ShimmerRenderer!
  // swiftlint:enable implicitly_unwrapped_optional

  // MARK: - View Life Cycle
  private func setupWarps(){

    warps = WarpZone(latitude: 45.76518, longitude: -73.990)
    
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    setupWarps()
    setupTileRenderer()
    WebView.scrollView.isScrollEnabled = false;
    let urls = URL(string: "http://192.168.56.1:6006/")!;
    WebView.load(URLRequest(url: urls))
    let initialRegion = MKCoordinateRegion(
      center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
      span: MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100))
    

    mapView.cameraZoomRange = MKMapView.CameraZoomRange(
      minCenterCoordinateDistance:6000000,
      maxCenterCoordinateDistance: 20000000)
    mapView.cameraBoundary = MKMapView.CameraBoundary(coordinateRegion: initialRegion)

    mapView.region = initialRegion
    mapView.showsUserLocation = true
    mapView.showsCompass = true
    mapView.setUserTrackingMode(.followWithHeading, animated: true)


    mapView.addAnnotation(warps)
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
//    self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
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
    case let warp as WarpZone:
      if let existingView = mapView.dequeueReusableAnnotationView(
        withIdentifier: WarpAnnotationView.identifier) {
        existingView.annotation = annotation
        return existingView
      } else {
        return WarpAnnotationView(annotation: warp, reuseIdentifier: WarpAnnotationView.identifier)
      }
    default:
      return nil
    }
  }
}

// MARK: - Game UI

