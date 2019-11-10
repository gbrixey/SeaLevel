import MapKit

/// Class that provides map tile overlay images showing areas that are under sea level
class SeaLevelMapOverlay: MKTileOverlay {

    let resourceManager: ResourceManager

    /// The current sea level.
    var seaLevel: Int = 0

    init(resourceManager: ResourceManager) {
        self.resourceManager = resourceManager
        super.init(urlTemplate: nil)
        minimumZ = ResourceManager.minZForTileImages
    }

    // MARK: - MKTileOverlay Overrides

    override func url(forTilePath path: MKTileOverlayPath) -> URL {
        return resourceManager.tileImageURL(forTilePath: path, seaLevel: seaLevel)
    }

    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        // Storing tile images for every zoom level would take up a lot of space, because the number of tiles
        // needed to cover the same area increases exponentially as the zoom level increases.
        //
        // Therefore, the tile images bundled with the app only go up to a certain zoom level,
        // indicated by `maxZForTileImages`. The tile images at this zoom level can be cropped and stretched
        // to create new tile images for higher zoom levels as needed.
        let maxZ = ResourceManager.maxZForTileImages
        guard path.z > maxZ else {
            return super.loadTile(at: path, result: result)
        }
        // Get the URL for the image file that contains the area represented by this tile path.
        // This is the image that will be cropped and resized.
        let scaleFactor = Int(pow(Double(2), Double(path.z - maxZ)))
        let newX = path.x / scaleFactor
        let newY = path.y / scaleFactor
        let newPath = MKTileOverlayPath(x: newX, y: newY, z: maxZ, contentScaleFactor: path.contentScaleFactor)
        let newURL = url(forTilePath: newPath)
        // If the containing tile is completely filled or completely empty, there's no need to crop and resize
        // since the image will look the same! Just load the same URL again.
        if newURL.absoluteString.contains("solid") || newURL.absoluteString.contains("clear") {
            return super.loadTile(at: newPath, result: result)
        }
        // Asynchronously request the containing tile image.
        let request = URLRequest(url: newURL)
        let dataTask = urlSession.dataTask(with: request) { (data, response, error) in
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

    // MARK: - Private

    private let urlSession = URLSession(configuration: .default)
}
