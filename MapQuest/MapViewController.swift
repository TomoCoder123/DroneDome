

import UIKit
import MapKit
import WebKit



class CustomButton: UIButton{ //Template for any buttons.
  
  
  private let myTitleLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 1
    label.textAlignment = .center
    return label
  }()
  
  private let mySubtitleLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 1
    label.textAlignment = .center
    return label
  }()
  
  private let myIconView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = .white
    
    return imageView
  }()
  override init(frame: CGRect){
    self.viewModel = nil
    super.init(frame: frame)
  }
  override func layoutSubviews(){
    super.layoutSubviews()
    
    myIconView.frame = CGRect(x: 5, y:5,
                              width: 100, height: frame.height).integral
    myTitleLabel.frame = CGRect(x: 60, y:5,
                                width: frame.width-65, height: (frame.height-10)/2).integral
    myTitleLabel.frame = CGRect(x: 60, y: (frame.height + 10)/2, width: frame.width-65, height: (frame.height-10)/2).integral
  }
  private var viewModel: MyCustomButtonViewModel? //Private to make it mutable.
  init(with viewModel: MyCustomButtonViewModel){

    
    self.viewModel = viewModel
    super.init(frame: .zero)
    
    addSubviews()

    configure(with: viewModel)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func addSubviews(){
    guard !myTitleLabel.isDescendant(of: self) else{
      return
    }
    addSubview(myTitleLabel)
    
    addSubview(mySubtitleLabel)
  
    addSubview(myIconView)
  }
  
  
  public func configure(with viewModel: MyCustomButtonViewModel){ //Allows configuring the button after it loads.
    layer.masksToBounds = true
    layer.cornerRadius = 8
    layer.borderColor = UIColor.secondarySystemBackground.cgColor
    layer.borderWidth = 1.5
    addSubviews()
    myTitleLabel.text = viewModel.title
    mySubtitleLabel.text = viewModel.subtitle
    myIconView.image = UIImage(systemName: viewModel.imageName)
  }
}
struct MyCustomButtonViewModel{ //Holds data that we pass to the model of the button
  let title: String
  let subtitle: String
  let imageName: String
  
}
public class MapViewController: UIViewController {
  
  private let cameraButton: CustomButton = {

    let camera = CustomButton(frame: CGRect(x:0, y: 0, width: 200, height: 60))
    camera.backgroundColor = .systemBlue
    return camera
  }()
  //Manages what is shown on the map/
  
  var globX: Double = -63.754138814196 //Sets the coordinates of the drone. These are the starting x and y coordinates.
  var globY: Double = 13.9317203835678

  func postCamera(camera: Int ){
    let url = URL(string: "http://192.168.4.27:5000/requester") //Sets the URL of the server connecting the drone to the app.
    guard let requestUrl = url else { fatalError() }
    // Prepares URL Request Object
    var request = URLRequest(url: requestUrl)
    request.httpMethod = "POST"
    //Post allows the app to send messsages to the server.
     
    // HTTP Request Parameters which will be sent in HTTP Request Body
    let postString = "camera=\(2)";
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
  func post(xcord x: Double,ycord y: Double){
    let url = URL(string: "http://192.168.4.27:5000/requester") //Sets the URL of the server connecting the drone to the app.
    guard let requestUrl = url else { fatalError() }
    // Prepares URL Request Object
    var request = URLRequest(url: requestUrl)
    request.httpMethod = "POST"
    //Post allows the app to send messsages to the server.
     
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
    getPos()//Requests the position of the drone from the server
    updatePos(longitude: self.globX, latitude: self.globY) //Updates the position of the drone on the map.
    repeatUpdateDrone()
  }
  
  func getPos() -> [Double] {
    
    var position = [0.0,0.0]
    // Create URL
    let url = URL(string: "http://192.168.4.27:5000")
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

  //Makes a DroneZone object and sets the initial position.
  var drone: DroneZone =  DroneZone(latitude: 45.76518, longitude: -73.990)
  
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var heartsLabel: UILabel!
  

  @IBAction func addPin(_ sender: UILongPressGestureRecognizer) {
    //Adds a pin after a long press gesture. Also tells the drone to move to that position.
    if(!(previous == nil)){ //If previous stores nothing, ignore. Otherwise remove the previous pin to create a new one.
      self.mapView.removeAnnotation(previous as! MKAnnotation)
    }
    let location = sender.location(in: self.mapView) //Tells where the mapView is being clicked
    let locCoord = self.mapView.convert(location, toCoordinateFrom: self.mapView)
 
    let annotation = MKPointAnnotation() //Creates a pin object.
    previous = annotation
    annotation.coordinate = locCoord
    annotation.title = "Drone Destination"
    annotation.subtitle = "Location of Destination"
    self.mapView.addAnnotation(annotation)
    self.post(xcord: annotation.coordinate.longitude, ycord: annotation.coordinate.latitude)
    //Sends the coordinates of the annotation to the server.

   
    
    
  }
  
  func updatePos(longitude: Double, latitude: Double){
   //Updates the position of the drone by the second.
    let deltax = latitude - drone.coordinate.latitude //Represents how much the latitude changed in one second.
    let deltay = longitude - drone.coordinate.longitude
      //Represents how much the longitude changed in one second.
    UIView.animate(withDuration: 1){
      //updates the drone one the map.
      self.drone.coordinate.latitude += deltax
      self.drone.coordinate.longitude += deltay
    }
    

  
  }
  @IBOutlet weak var WebView: WKWebView!
  
  

  var tileRenderer: MKTileOverlayRenderer!
  


  private func setupdrone(){

    drone = DroneZone(latitude: 45.76518, longitude: -73.99)
    //Creates the drone icon and initializes the locaiton.
  }
  @objc func changeCamera(){
    
  }
  override public func viewDidLoad() {
    //Shows the initial view.
    super.viewDidLoad()
    view.addSubview(cameraButton)
    cameraButton.center = view.center
    let viewModel = MyCustomButtonViewModel(title: "Change Camera", subtitle:"Camera options", imageName: "camera")

    cameraButton.configure(with: viewModel)
    cameraButton.addTarget(self, action: #selector(self.changeCamera), for: .touchUpInside)
    setupdrone()
    setupTileRenderer()
    WebView.scrollView.isScrollEnabled = false;
    let urls = URL(string: "http://192.168.4.27:5000/video_feed")!;
    WebView.load(URLRequest(url: urls))
    
    let initialRegion = MKCoordinateRegion(
      center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
      span: MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100))
    //Sets the initial range of the view of the map.
    
    //Sets the zoom range of the mpa.
    mapView.cameraZoomRange = MKMapView.CameraZoomRange(
      minCenterCoordinateDistance:6000000,
      maxCenterCoordinateDistance: 20000000)
    mapView.cameraBoundary = MKMapView.CameraBoundary(coordinateRegion: initialRegion)

    mapView.region = initialRegion
    mapView.showsUserLocation = true
    mapView.showsCompass = true
    mapView.setUserTrackingMode(.followWithHeading, animated: true)


    mapView.addAnnotation(drone)
    mapView.delegate = self
  }

  override public func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    repeatUpdateDrone() //Starts the drone update loop.
  }

  func repeatUpdateDrone() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { [weak self] in
      self?.updateDrone() //This is the drone update loop.
    })

  }
  private func setupTileRenderer() { //Sets up the satellite view tiles.
    let overlay = SatelliteView()

    overlay.canReplaceMapContent = true
    mapView.addOverlay(overlay, level: .aboveLabels)
    tileRenderer = MKTileOverlayRenderer(tileOverlay: overlay)

    overlay.minimumZ = 3 //Sets the minimum zoom layer
    overlay.maximumZ = 5
  }

  @objc public func gameUpdated(notification: Notification) {
  }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
  // Add delegates here
  
  public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      return tileRenderer //When the map wants to return a tile, it calls this function.
    
  }

  public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

    switch annotation {
    
    case let user as MKUserLocation:

      if let existingView = mapView.dequeueReusableAnnotationView(withIdentifier: "user") {
        return existingView
      } else {
        let view = MKAnnotationView(annotation: user, reuseIdentifier: "user")
        
        view.image = #imageLiteral(resourceName: "user")
        return view
        
      }
      //Returns an annotation view as a drone annotation.
    case let Drone as DroneZone:
      if let existingView = mapView.dequeueReusableAnnotationView(
        withIdentifier: DroneAnnotationView.identifier) {
        existingView.annotation = annotation
        return existingView
      } else {
        return DroneAnnotationView(annotation: Drone, reuseIdentifier: DroneAnnotationView.identifier)
      }
    default:
      return nil
    }
  }
}

// MARK: - Game UI

