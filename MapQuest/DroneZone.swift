

import MapKit
import UIKit

@objc class DroneZone: NSObject, MKAnnotation {
  // MARK: - Properties
  @objc dynamic var coordinate: CLLocationCoordinate2D
 

  // MARK: - Initializers
  init(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
    self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    
    super.init()
  }
}

extension DroneZone {
  var image: UIImage {
    // swiftlint:disable:next discouraged_object_literal
    return #imageLiteral(resourceName: "Drone")
  }
}

class DroneAnnotationView: MKAnnotationView {
  static let identifier = "DroneZone"

  override var annotation: MKAnnotation? {
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
    UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
    // swiftlint:disable:next force_unwrapping
    let context = UIGraphicsGetCurrentContext()!

    color.setFill()

    context.translateBy(x: 0, y: size.height)
    context.scaleBy(x: 1.0, y: -1.0)

    let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
    // swiftlint:disable:next force_unwrapping
    context.draw(cgImage!, in: rect)

    context.setBlendMode(.sourceIn)
    context.addRect(rect)
    context.drawPath(using: .fill)

    let coloredImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    // swiftlint:disable:next force_unwrapping
    return coloredImage!
  }
}

