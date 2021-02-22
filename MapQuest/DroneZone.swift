

import MapKit
import UIKit

@objc class DroneZone: NSObject, MKAnnotation {
  // MARK: - Properties
  @objc dynamic var coordinate: CLLocationCoordinate2D
 

  // MARK: - Initializers
  init(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
    self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude) //Initializes the coordinate of the drone.
    
    super.init()
  }
}

extension DroneZone {
  var image: UIImage {

    return #imageLiteral(resourceName: "Drone") //Sets the drone image
  }
}

class DroneAnnotationView: MKAnnotationView {
  //Represents the drone icon.
  static let identifier = "DroneZone"

  override var annotation: MKAnnotation? { //Overrides the default annotation to set the icon as the Drone image.
    get { super.annotation }
    set {
      super.annotation = newValue
      guard let Drone = newValue as? DroneZone else { return }

      self.image = Drone.image
    }
  }
}

extension UIImage {
  func maskWithColor(color: UIColor) -> UIImage {
    //Sets some settings for the drone image.
    UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
    // swiftlint:disable:next force_unwrapping
    let context = UIGraphicsGetCurrentContext()!

    color.setFill()

    context.translateBy(x: 0, y: size.height)
    context.scaleBy(x: 1.0, y: -1.0)

    let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
    
    context.draw(cgImage!, in: rect)

    context.setBlendMode(.sourceIn)
    context.addRect(rect)
    context.drawPath(using: .fill)

    let coloredImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

   
    return coloredImage!
  }
}

