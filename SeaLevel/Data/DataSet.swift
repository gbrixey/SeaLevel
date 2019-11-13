import MapKit

enum DataSet: String, CaseIterable {
    case jakartaSRTM
    case londonSRTM
    case miamiSRTM
    case newYorkCitySRTM
    case tokyoSRTM

    var resourceName: String {
        return rawValue
    }

    var index: Int {
        return DataSet.allCases.firstIndex(of: self)!
    }

    // MARK: - Metadata
    // This metadata could also be stored in a file instead of hardcoded for each enum case.

    var region: MKCoordinateRegion {
        let tuple: (CLLocationDegrees, CLLocationDegrees, CLLocationDegrees, CLLocationDegrees)
        switch self {
        case .jakartaSRTM:     tuple = (-6.315299, 106.787109, 0.7, 0.5)
        case .londonSRTM:      tuple = (51.508742, -0.175781,  0.7, 0.7)
        case .miamiSRTM:       tuple = (26.194877, -80.244141, 1.7, 0.5)
        case .newYorkCitySRTM: tuple = (40.713956, -74.003906, 0.7, 0.7)
        case .tokyoSRTM:       tuple = (35.675147, 139.833984, 0.8, 0.8)
        }
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: tuple.0, longitude: tuple.1),
                                  span: MKCoordinateSpan(latitudeDelta: tuple.2, longitudeDelta: tuple.3))
    }

    var infoTitle: String {
        return String(format: String(key: "info.title.format.srtm"), String(key: "info.title.\(resourceName)"))
    }

    var infoText: String {
        return String(key: "info.srtm.text")
    }

    var searchTitle: String {
        return String(key: "search.\(resourceName)")
    }
}
