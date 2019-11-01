import MapKit

extension MKCoordinateRegion {

    /// The default region encompasses the NYC area.
    static var defaultRegion: MKCoordinateRegion {
        let coordinate = CLLocationCoordinate2D(latitude: 40.713956, longitude: -74.003906)
        let span = MKCoordinateSpan(latitudeDelta: 0.7, longitudeDelta: 0.7)
        return MKCoordinateRegion(center: coordinate, span: span)
    }

    /// Converts the coordinate region to a map rect.
    var mapRect: MKMapRect {
        let topLeft = CLLocationCoordinate2D(latitude: center.latitude + span.latitudeDelta / 2,
                                             longitude: center.longitude - span.longitudeDelta / 2)
        let bottomRight = CLLocationCoordinate2D(latitude: center.latitude - span.latitudeDelta / 2,
                                                 longitude: center.longitude + span.longitudeDelta / 2)
        // These corners are not always the top left and bottom right, hence why the name is changed.
        let cornerA = MKMapPoint(topLeft)
        let cornerB = MKMapPoint(bottomRight)
        let origin = MKMapPoint(x: min(cornerA.x, cornerB.x), y: min(cornerA.y, cornerB.y))
        let size = MKMapSize(width: abs(cornerA.x - cornerB.x), height: abs(cornerA.y - cornerB.y))
        return MKMapRect(origin: origin, size: size)
    }
}
