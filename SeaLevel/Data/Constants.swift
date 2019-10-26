import MapKit

extension MKCoordinateRegion {

    static var defaultRegion: MKCoordinateRegion {
        let coordinate = CLLocationCoordinate2D(latitude: 40.713956, longitude: -74.003906)
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        return MKCoordinateRegion(center: coordinate, span: span)
    }
}

extension String {

    init(key: String) {
        self = NSLocalizedString(key, comment: "")
    }
}
