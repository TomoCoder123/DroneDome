

import Foundation
import MapKit

extension PointOfInterest: MKAnnotation {
  var coordinate: CLLocationCoordinate2D { return location.coordinate }
  var title: String? { return name }
}
