import MapKit

extension MKCoordinateRegion {

    static var nyc: MKCoordinateRegion {
        let coordinate = CLLocationCoordinate2D(latitude: 40.7, longitude: -74)
        let span = MKCoordinateSpan(latitudeDelta: 0.8, longitudeDelta: 0.8)
        return MKCoordinateRegion(center: coordinate, span: span)
    }
}
