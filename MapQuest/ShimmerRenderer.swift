
import UIKit
import MapKit

class ShimmerRenderer: MKPolygonRenderer {
  // MARK: - Properties
  var iteration = 0
  var locations: [CGFloat] = [0, 0, 0]

  func updateLocations() {
    iteration = (iteration + 1) % 15
    let minL = max(0, CGFloat(iteration - 1) / 15.0)
    let maxL = min(1.0, CGFloat(iteration + 1) / 15.0)
    let center = CGFloat(iteration) / 15.0
    locations = [minL, center, maxL]
  }

  // MARK: - Overridden
  override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
    super.draw(mapRect, zoomScale: zoomScale, in: context)

    UIGraphicsPushContext(context)

    let boundingRect = path.boundingBoxOfPath
    let minX = boundingRect.minX
    let maxX = boundingRect.maxX

    // swiftlint:disable:next discouraged_object_literal
    let colors = [#colorLiteral(red: 0.2431372549, green: 0.5803921569, blue: 0.9764705882, alpha: 1).cgColor, #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 0.8523706897).cgColor, #colorLiteral(red: 0.2431372549, green: 0.5803921569, blue: 0.9764705882, alpha: 1).cgColor]
    let gradient = CGGradient(colorsSpace: nil, colors: colors as CFArray, locations: locations)
    context.addPath(self.path)
    context.clip()
    context.drawLinearGradient(gradient!, start: CGPoint(x: minX, y: 0), end: CGPoint(x: maxX, y: 0), options: [])
    // swiftlint:disable:previous force_unwrapping

    UIGraphicsPopContext()
  }
}
