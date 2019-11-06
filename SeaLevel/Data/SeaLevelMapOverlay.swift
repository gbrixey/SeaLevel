import MapKit

/// Class that provides map tile overlay images showing areas that are under sea level
class SeaLevelMapOverlay: MKTileOverlay {
    /// The minimum zoom level for which overlay images are shown.
    static let minimumSupportedZoomLevel = 9

    var seaLevel: Int = 0

    init() {
        super.init(urlTemplate: nil)
        minimumZ = SeaLevelMapOverlay.minimumSupportedZoomLevel
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

    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        // Storing tile images for every zoom level would take up a lot of space, because the number of tiles
        // needed to cover the same area increases exponentially as the zoom level increases.
        //
        // Therefore, the tile images bundled with the app only go up to a certain zoom level,
        // indicated by `maxZForTileImages`. The tile images at this zoom level can be cropped and stretched
        // to create new tile images for higher zoom levels as needed.
        guard path.z > maxZForTileImages else {
            return super.loadTile(at: path, result: result)
        }
        // Get the URL for the image file that contains the area represented by this tile path.
        // This is the image that will be cropped and resized.
        let scaleFactor = Int(pow(Double(2), Double(path.z - maxZForTileImages)))
        let newX = path.x / scaleFactor
        let newY = path.y / scaleFactor
        let newPath = MKTileOverlayPath(x: newX, y: newY, z: maxZForTileImages, contentScaleFactor: path.contentScaleFactor)
        let newURL = url(forTilePath: newPath)
        // If the containing tile is completely filled or completely empty, there's no need to crop and resize
        // since the image will look the same! Just load the same URL again.
        if newURL.absoluteString.contains("solid") || newURL.absoluteString.contains("clear") {
            return super.loadTile(at: newPath, result: result)
        }
        // Asynchronously request the containing tile image.
        let request = URLRequest(url: newURL)
        let dataTask = SeaLevelMapOverlay.urlSession.dataTask(with: request) { (data, response, error) in
            guard error == nil, let data2 = data, let image = UIImage(data: data2), let cgImage = image.cgImage else {
                return result(data, error)
            }
            let imageSize = 256
            let imageX = newX * scaleFactor
            let imageY = newY * scaleFactor
            let xOffset = path.x - imageX
            let yOffset = path.y - imageY
            let interval = imageSize / scaleFactor
            let cropRect = CGRect(x: xOffset * interval,
                                  y: yOffset * interval,
                                  width: interval,
                                  height: interval)
            let croppedCGImage = cgImage.cropping(to: cropRect)!
            let croppedImage = UIImage(cgImage: croppedCGImage, scale: 1.0, orientation: .up)
            let newRect = CGRect(x: 0, y: 0, width: imageSize, height: imageSize)
            UIGraphicsBeginImageContextWithOptions(newRect.size, false, 1.0)
            croppedImage.draw(in: newRect)
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            result(resizedImage.pngData(), error)
        }
        dataTask.resume()
    }

    private static let urlSession = URLSession(configuration: .default)

    /// The highest zoom level for which tile images are bundled with the app.
    /// The tile images at this zoom level will be cropped and resized to provide tile images at higher zoom levels.
    private let maxZForTileImages = 13

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
