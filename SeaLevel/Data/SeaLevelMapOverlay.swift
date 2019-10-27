import MapKit

/// Class that provides map tile overlay images showing areas that are under sea level
class SeaLevelMapOverlay: MKTileOverlay {
    let seaLevel: Int

    init(seaLevel: Int) {
        self.seaLevel = seaLevel
        super.init(urlTemplate: nil)
        minimumZ = 11
        maximumZ = 14
    }

    override func url(forTilePath path: MKTileOverlayPath) -> URL {
        let resource = "z\(path.z)x\(path.x)y\(path.y)e\(seaLevel)"
        // Normal case: return the tile image if it exists.
        if let tilePath = Bundle.main.url(forResource: resource, withExtension: "png") {
            return tilePath
        }
        // If the tile image doesn't exist, it means one of three things.
        //    1. There is no data for this tile at all.
        //    2. The tile is currently completely above sea level (i.e. the overlay image is entirely transparent)
        //    3. The tile is currently completely below sea level (i.e. the overlay image is a solid color)
        //
        // Cases 2 and 3 occur frequently, especially at high zoom levels. Instead of storing a lot of identical
        // solid or transparent images for these cases, there is only one solid and one transparent image.
        //
        // Case 2 is handled first. Check the data store to see if the current sea level is above the maximum elevation
        // for this tile. If so, then return the solid image.
        if let maximumElevation = SeaLevelDataStore.shared.maximumElevation(z: path.z, x: path.x, y: path.y),
            seaLevel >= maximumElevation {
            return Bundle.main.url(forResource: "solid", withExtension: "png")!
        }
        // If there is no recorded maximum elevation, or if the maximum elevation is above the current sea level,
        // then this tile falls into either case 1 or 2 as described above, so return the transparent overlay image.
        return Bundle.main.url(forResource: "clear", withExtension: "png")!
    }

    // Static data store for managing the maximum elevation map.
    private class SeaLevelDataStore {

        static let shared = SeaLevelDataStore()
        private var map: [UInt64: UInt16] = [:]

        init() {
            // Load data from file into the maximum elevation map.
            let url = Bundle.main.url(forResource: "solid", withExtension: "dat")!
            let stream = InputStream(url: url)!
            stream.open()
            // Each tile is represented by four 16-bit integers.
            // The first three are the tile coordinates Z, X, and Y, and the fourth one is the maximum elevation.
            var buffer: [UInt8] = [0, 0, 0, 0, 0, 0, 0, 0]
            while stream.hasBytesAvailable {
                stream.read(&buffer, maxLength: buffer.count)
                // The key for the map is a 64-bit integer created by bit shifting the Z, X, and Y values.
                let k = buffer.prefix(6).map { UInt64($0) }
                let key = k[1] << 40 + k[0] << 32 + k[3] << 24 + k[2] << 16 + k[5] << 8 + k[4]
                let elevation = UInt16(buffer[7]) << 8 + UInt16(buffer[6])
                map[key] = elevation
            }
        }

        /// Get the maximum elevation for the tile at the given coordinates.
        /// - returns: The maximum elevation. Returns nil if the maximum elevation is above 100 meters or is unknown.
        func maximumElevation(z: Int, x: Int, y: Int) -> Int? {
            let key = UInt64(z) << 32 + UInt64(x) << 16 + UInt64(y)
            return map[key].map { Int($0) }
        }
    }
}
