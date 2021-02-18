

import MapKit
import UIKit

@objc class WarpZone: NSObject, MKAnnotation {
  // MARK: - Properties
  @objc dynamic var coordinate: CLLocationCoordinate2D
 

  // MARK: - Initializers
  init(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
    self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    
    super.init()
  }
}

extension WarpZone {
  var image: UIImage {
    // swiftlint:disable:next discouraged_object_literal
    return #imageLiteral(resourceName: "warp")
  }
}

class WarpAnnotationView: MKAnnotationView {
  static let identifier = "WarpZone"

  override var annotation: MKAnnotation? {
    get { super.annotation }
    set {
      super.annotation = newValue
      guard let warp = newValue as? WarpZone else { return }

      self.image = warp.image
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

