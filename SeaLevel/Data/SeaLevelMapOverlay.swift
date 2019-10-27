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
        if let tilePath = Bundle.main.url(forResource: resource, withExtension: "png") {
            return tilePath
        } else if let maximumElevation = SeaLevelDataStore.shared.maximumElevation(z: path.z, x: path.x, y: path.y),
            elevation >= maximumElevation {
            return Bundle.main.url(forResource: "solid", withExtension: "png")!
        } else {
            return Bundle.main.url(forResource: "clear", withExtension: "png")!
        }
    }

    private class SeaLevelDataStore {

        static let shared = SeaLevelDataStore()
        private var map: [UInt64: UInt16] = [:]

        init() {
            let url = Bundle.main.url(forResource: "solid", withExtension: "dat")!
            let stream = InputStream(url: url)!
            stream.open()
            var buffer: [UInt8] = [0, 0, 0, 0, 0, 0, 0, 0]
            while stream.hasBytesAvailable {
                stream.read(&buffer, maxLength: buffer.count)
                let k = buffer.prefix(6).map { UInt64($0) }
                let key = k[0] << 40 + k[1] << 32 + k[2] << 24 + k[3] << 16 + k[4] << 8 + k[5]
                let elevation = UInt16(buffer[6]) << 8 + UInt16(buffer[5])
                map[key] = elevation
            }
        }

        func maximumElevation(z: Int, x: Int, y: Int) -> Int? {
            let key = UInt64(z) << 32 + UInt64(x) << 16 + UInt64(y)
            return map[key].map { Int($0) }
        }
    }
}
