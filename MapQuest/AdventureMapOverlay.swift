
import Foundation
import MapKit

class AdventureMapOverlay: MKTileOverlay {
  override func url(forTilePath path: MKTileOverlayPath) -> URL {
    print("\(path.z) \(path.x) \(path.y)")
    let tilePath = Bundle.main.url(
      forResource: "\(path.y)",
      withExtension: "png",
      subdirectory: "tiles/\(path.z)/\(path.x)",
      localization: nil)

    if let tile = tilePath {
      return tile
    } else {
      return Bundle.main.url(
        forResource: "parchment",
        withExtension: "png",
        subdirectory: "tiles",
        localization: nil)!
      // swiftlint:disable:previous force_unwrapping
    }
  }
}
