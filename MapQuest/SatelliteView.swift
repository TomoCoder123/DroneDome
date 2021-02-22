
import Foundation
import MapKit

class SatelliteView: MKTileOverlay {
  override func url(forTilePath path: MKTileOverlayPath) -> URL { //The function url takes in a MKTileOverlayPath object to create a filepath for the satellite tiles.

    let tilePath = Bundle.main.url(
      forResource: "\(path.y)",
      withExtension: "png",
      subdirectory: "tiles/\(path.z)/\(path.x)",
      localization: nil)

    if let tile = tilePath { // If there is a satellite image, return the available tile. Otherwise, return a parchment tile, a placeholder tile.
      return tile
    } else {
      return Bundle.main.url(
        forResource: "parchment",
        withExtension: "png",
        subdirectory: "tiles",
        localization: nil)!
 
    }
  }
}
