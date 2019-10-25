import MapKit

extension MKCoordinateRegion {

    static var defaultRegion: MKCoordinateRegion {
        let coordinate = CLLocationCoordinate2D(latitude: 40.780508, longitude: -73.916016)
        let span = MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25)
        return MKCoordinateRegion(center: coordinate, span: span)
    }
}
