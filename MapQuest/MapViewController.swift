

import UIKit
import MapKit
import WebKit
public class MapViewController: UIViewController {
  // MARK: - IBOutlets
//  let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateDrone(_:)), userInfo: nil, repeats: true)
  
  var globX: Double = -63.754138814196
  var globY: Double = 13.9317203835678

  func post(xcord x: Double,ycord y: Double){
    let url = URL(string: "http://192.168.4.27:5000/requester")
    guard let requestUrl = url else { fatalError() }
    // Prepare URL Request Object
    var request = URLRequest(url: requestUrl)
    request.httpMethod = "POST"
     
    // HTTP Request Parameters which will be sent in HTTP Request Body
    let postString = "xpos=\(x)&ypos=\(y)";
    // Set HTTP Request Body
    request.httpBody = postString.data(using: String.Encoding.utf8);
    request.setValue("application/json", forHTTPHeaderField: "Accept")
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
  
  @objc public func updateDrone() {
    var arr = getPos()
    arr[0] = self.globX
    arr[1] = self.globY
    print("\(arr) my reason...")
    updatePos(longitude: arr[0], latitude: arr[1])
    repeatUpdateDrone()
  }
  
  func getPos() -> [Double] {
    
    var position = [0.0,0.0]
    // Create URL
    let url = URL(string: "http://192.168.4.27:5000/requester")
    guard let requestUrl = url else { fatalError() }
    // Create URL Request
    var request = URLRequest(url: requestUrl)
    // Specify HTTP Method to use
    request.httpMethod = "GET"
    // Send HTTP Request
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        
        // Check if Error took place
        if let error = error {
            print("Error took place \(error)")
            return
        }
        
        // Read HTTP Response Status code
        if let response = response as? HTTPURLResponse {
            print("Response HTTP Status code: \(response.statusCode)")
        }
        
        // Convert HTTP Response Data to a simple String
        if let data = data, let dataString = String(data: data, encoding: .utf8) {
            print("Response data string:\n \(dataString)")
        }
        do {
            if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                  // Print out entire dictionary
                  print(convertedJsonIntoDict["x"] as! Double)
                  // Get value by key
              self.globX = convertedJsonIntoDict["x"] as! Double
              self.globY = convertedJsonIntoDict["y"] as! Double
              print("\(self.globY) this is my 13th reason")
                     
                 }
              } catch let error as NSError {
                 print(error.localizedDescription)
       }

      }
    print(position)

    task.resume()
    return position
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
    self.post(xcord: annotation.coordinate.longitude, ycord: annotation.coordinate.latitude)
    //updatePos(longitude: annotation.coordinate.longitude, latitude: annotation.coordinate.latitude)
   
    
    
  }
  
  func updatePos(longitude: Double, latitude: Double){
   
    let deltax = latitude - warps.coordinate.latitude
    let deltay = longitude - warps.coordinate.longitude
//    print(latitude)
//    print(longitude)
//    print(warps.coordinate.latitude)
//    print(warps.coordinate.longitude)

    UIView.animate(withDuration: 1){
      self.warps.coordinate.latitude += deltax
      self.warps.coordinate.longitude += deltay
    }
    

  
  }
  @IBOutlet weak var WebView: WKWebView!
  
  
  // MARK: - Properties
  // swiftlint:disable implicitly_unwrapped_optional
  var tileRenderer: MKTileOverlayRenderer!
  // swiftlint:enable implicitly_unwrapped_optional

  // MARK: - View Life Cycle
  private func setupWarps(){

    warps = WarpZone(latitude: 45.76518, longitude: -73.990)
    
  }
  override public func viewDidLoad() {
    super.viewDidLoad()
    setupWarps()
    setupTileRenderer()
    WebView.scrollView.isScrollEnabled = false;
    let urls = URL(string: "http://192.168.4.27:5000/video_feed")!;
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

  override public func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    repeatUpdateDrone()
  }

  func repeatUpdateDrone() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { [weak self] in
      self?.updateDrone()
    })

  }
  private func setupTileRenderer() {
    let overlay = AdventureMapOverlay()

    overlay.canReplaceMapContent = true
    mapView.addOverlay(overlay, level: .aboveLabels)
    tileRenderer = MKTileOverlayRenderer(tileOverlay: overlay)

    overlay.minimumZ = 3
    overlay.maximumZ = 5
  }

  @objc public func gameUpdated(notification: Notification) {
  }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
  // Add delegates here
  public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      return tileRenderer
    
  }

  public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
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

