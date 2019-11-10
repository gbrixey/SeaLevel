import MapKit

enum DataSet: String, CaseIterable {
    case londonSRTM
    case newYorkCitySRTM

    var resourceName: String {
        return rawValue
    }

    var index: Int {
        return DataSet.allCases.firstIndex(of: self)!
    }

    // MARK: - Metadata
    // This metadata could also be stored in a file instead of hardcoded for each enum case.

    var region: MKCoordinateRegion {
        switch self {
        case .londonSRTM:
            return MKCoordinateRegion(latitude: 51.508742, longitude: -0.175781, latDelta: 0.7, lonDelta: 0.7)
        case .newYorkCitySRTM:
            return MKCoordinateRegion(latitude: 40.713956, longitude: -74.003906, latDelta: 0.7, lonDelta: 0.7)
        }
    }

    var infoTitle: String {
        switch self {
        case .londonSRTM:
            return String(key: "info.srtm.title.london")
        case .newYorkCitySRTM:
            return String(key: "info.srtm.title.nyc")
        }
    }

    var infoText: String {
        switch self {
        case .londonSRTM, .newYorkCitySRTM:
            return String(key: "info.srtm.text")
        }
    }

    var searchTitle: String {
        switch self {
        case .londonSRTM:
            return String(key: "search.srtm.london")
        case .newYorkCitySRTM:
            return String(key: "search.srtm.nyc")
        }
    }
}
