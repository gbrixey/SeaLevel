import MapKit

extension MKCoordinateRegion {

    /// The default region encompasses the NYC area.
    static var defaultRegion: MKCoordinateRegion {
        let coordinate = CLLocationCoordinate2D(latitude: 40.713956, longitude: -74.003906)
        let span = MKCoordinateSpan(latitudeDelta: 0.7, longitudeDelta: 0.7)
        return MKCoordinateRegion(center: coordinate, span: span)
    }
}

extension Double {

    /// The initial sea level is 1.0 so that the app will start off showing overlay tiles.
    /// If the sea level is set to 0, then no tiles are shown, because the map already reflects the current sea level.
    static var initialSeaLevel: Double { 1.0 }
}

extension String {

    init(key: String) {
        self = NSLocalizedString(key, comment: "")
    }
}
