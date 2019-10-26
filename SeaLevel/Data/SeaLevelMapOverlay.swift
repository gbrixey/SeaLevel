import MapKit

class SeaLevelMapOverlay: MKTileOverlay {
    let elevation: Int

    init(elevation: Int) {
        self.elevation = elevation
        super.init(urlTemplate: nil)
        minimumZ = 11
        maximumZ = 14
    }

    override func url(forTilePath path: MKTileOverlayPath) -> URL {
        let resource = "z\(path.z)x\(path.x)y\(path.y)e\(elevation)"
        let tilePath = Bundle.main.url(forResource: resource, withExtension: "png")
        return tilePath ?? Bundle.main.url(forResource: "clear", withExtension: "png")!
    }
}
