import MapKit

class SeaLevelMapOverlay: MKTileOverlay {

    override func url(forTilePath path: MKTileOverlayPath) -> URL {
        // This is where tile overlays showing the effects of sea level rise would be returned.
        // I don't have the data, so this function just returns a transparent overlay.
        return Bundle.main.url(forResource: "clear", withExtension: "png")!
    }
}
