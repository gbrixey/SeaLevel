import Foundation
import ZIPFoundation
import MapKit

/// Class responsible for managing tile images and other data resources on disk.
class ResourceManager: ObservableObject {

    static let shared = ResourceManager()

    /// The minimum zoom level for which tile overlay images are shown.
    static let minZForTileImages = 9

    /// The highest zoom level for which tile images are bundled with the app.
    /// The tile images at this zoom level will be cropped and resized to provide tile images at higher zoom levels.
    static let maxZForTileImages = 13

    @Published private(set) var isLoading = false
    private(set) var progress = Progress()
    private(set) var error: Error?

    var currentDataRegion: MKCoordinateRegion {
        // This data could also be stored in a file instead of hardcoded for each enum case.
        switch currentDataSet {
        case .londonSRTM:
            return MKCoordinateRegion(latitude: 51.508742, longitude: -0.175781, latDelta: 0.7, lonDelta: 0.7)
        case .newYorkCitySRTM:
            return MKCoordinateRegion(latitude: 40.713956, longitude: -74.003906, latDelta: 0.7, lonDelta: 0.7)
        }
    }

    func ensureInitialData() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            self.unzipCurrentDataSet()
            self.loadMaximumElevationMapForCurrentDataSet()
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }

    /// Returns a tile image URL for the given tile coordinates and sea level setting.
    func tileImageURL(forTilePath path: MKTileOverlayPath, seaLevel: Int) -> URL {
        // First check to see if the current sea level is above the maximum elevation for this tile.
        // If so, then return the solid image.
        if let maximumElevation = maximumElevation(z: path.z, x: path.x, y: path.y), seaLevel >= maximumElevation {
            return ResourceManager.solidTileURL
        }
        // If we can't find the tile image URL, use the transparent tile image as a default.
        guard let baseURL = currentDataSetDirectoryURL else {
            return ResourceManager.clearTileURL
        }
        let tileImageURL = baseURL
            .appendingPathComponent("\(path.z)")
            .appendingPathComponent("\(path.x)")
            .appendingPathComponent("\(currentDataSet)_z\(path.z)x\(path.x)y\(path.y)e\(seaLevel)")
            .appendingPathExtension("png")
        if fileManager.fileExists(atPath: tileImageURL.relativePath) {
            return tileImageURL
        } else {
            // If the tile image doesn't exist, it means we don't have any data for this tile
            // or the tile is completely above sea level. In both of these cases, we show a transparent image.
            return ResourceManager.clearTileURL
        }
    }

    // MARK: - Private

    private static let defaultDataSet: DataSet = .londonSRTM
    private static var solidTileURL: URL { Bundle.main.url(forResource: "solid", withExtension: "png")! }
    private static var clearTileURL: URL { Bundle.main.url(forResource: "clear", withExtension: "png")! }

    private let fileManager = FileManager.default
    private var currentDataSet = ResourceManager.defaultDataSet

    /// This dictionary stores maximum elevations for tiles in the current data set.
    /// The keys of the dictionary are created by combining the tile coordinates into a single integer.
    private var maximumElevationMap: [UInt64: UInt16] = [:]

    private var tilesURL: URL? {
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        return documentsURL?.appendingPathComponent("Tiles", isDirectory: true)
    }

    private var currentDataSetDirectoryURL: URL? {
        return tilesURL?.appendingPathComponent(currentDataSet.resourceName)
    }

    private func unzipCurrentDataSet() {
        guard let sourceURL = Bundle.main.url(forResource: currentDataSet.resourceName, withExtension: "zip"),
            let destinationURL = tilesURL else {
                return
        }
        do {
            try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            try fileManager.unzipItem(at: sourceURL, to: destinationURL, progress: progress)
        } catch {
            // If we get a "file exists" error, it probably means the data was already unzipped.
            // In this case we can ignore the error.
            let nsError = error as NSError
            if nsError.domain == NSCocoaErrorDomain && nsError.code == NSFileWriteFileExistsError {
                return
            }
            DispatchQueue.main.async {
                self.error = error
            }
        }
    }

    /// Get the maximum elevation for the tile at the given coordinates.
    /// - returns: The maximum elevation. Returns nil if the maximum elevation is above 100 meters or is unknown.
    private func maximumElevation(z: Int, x: Int, y: Int) -> Int? {
        let key = UInt64(z) << 32 + UInt64(x) << 16 + UInt64(y)
        return maximumElevationMap[key].map { Int($0) }
    }

    private func loadMaximumElevationMapForCurrentDataSet() {
        maximumElevationMap = [:]
        guard let url = currentDataSetDirectoryURL?
            .appendingPathComponent("\(currentDataSet)_solid")
            .appendingPathExtension("dat"),
            let stream = InputStream(url: url) else {
                return
        }
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
            maximumElevationMap[key] = elevation
        }
        stream.close()
    }
}
